//
//  Player.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Player.h"
#import "Platform.h"
#import "FinishLine.h"
#import "Chunk.h"
#import "UnswappablePlatform.h"
CGFloat jumpPosition;
id PlayerJump;
CGFloat YVelocity;
const CGFloat fullGravity = 1.4;
CGFloat gravity = 1;
const CGFloat reducedGravity = .37;
const CGFloat jumpSpeed = 8;
const CGFloat terminalVelocity = 6;
bool Jumping;//if in the air at all
bool Falling;//if going down
bool JumpButtonDown;//if the jump button is down while player is in the air
bool canSwap;//false when jumping and when on an unswappable platform
bool Dead;
ALuint runEffect;
@implementation Player
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap
{
    if((self=[super fileInitWithFrame:@"Goo_Happy_Run1.png" swapvalue:swap]))
    {
        self.position= ccp(x,[plat giveHeight:self]);
        [self makeAnimations];
        [self runAction:walkAction];
        runEffect = [[SimpleAudioEngine sharedEngine] playLoopEffect:@"Run.caf"];
        YVelocity = 0;
        gravity = fullGravity;
        Jumping = false;
        JumpButtonDown = false;
        Falling = false;
        Dead = false;
        canSwap = true;
    }
    return self;
}
-(ALuint) getRunEffect
{
    return runEffect;
}
-(bool) getDead
{
    return  Dead;
}
-(void) makeAnimations
{
    //walk animation 
    NSMutableArray *walkanimframes = [NSMutableArray array];
    for(int i = 1; i <= 8; ++i) 
    {
        [walkanimframes addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Goo_Happy_Run%d.png", i]]];
    }
    CCAnimation* walkAnimation = [CCAnimation animationWithFrames:walkanimframes delay:0.03f];
    self ->walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimation restoreOriginalFrame:NO]]; 
    [self->walkAction retain];
    //jump animation
    NSMutableArray *jumpanimframes = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) 
    {
        [jumpanimframes addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Goo_Happy_Jump%d.png", i]]];
    }
    self->jumpAction = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:jumpanimframes delay:0.03f]restoreOriginalFrame:NO];
    [self->jumpAction retain];
    //death animation
    NSMutableArray *deathanimframes = [NSMutableArray array];
    for(int i = 1; i <= 36; ++i) 
    {
        [deathanimframes addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"death_animation%d.png", i]]];
    }
    self->dieAction = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:deathanimframes delay:0.015f]restoreOriginalFrame:NO];
    [self->dieAction retain];
}
-(void) Update: (NSMutableArray*) platforms unswappableplats: (NSMutableArray*) unswappableplatforms spike: (NSMutableArray*) spikes saw: (NSMutableArray*) saws
{
    [self JumpUpdate];
    [self offPlatform:platforms unswappableplats:unswappableplatforms];
    [self spikesOnOtherSide:spikes saw:saws];
    self.position = ccp(position_.x, position_.y+YVelocity);
}
-(void) playerStopJump//stops the player jump
{
    Jumping = false;
    Falling = false;
    JumpButtonDown = false;
    YVelocity = 0;
}
-(void) playerJump
{
    if(!Jumping)
    {
        if(!Swapped)
        {
            YVelocity = jumpSpeed;
        }
        else
        {
            YVelocity = -jumpSpeed;
        }
        [self stopAllActions];
        [self runAction:jumpAction];
        JumpButtonDown = true;
        Jumping = true;
        [[SimpleAudioEngine sharedEngine]playEffect:@"jump.caf"];
        [[SimpleAudioEngine sharedEngine]stopEffect:runEffect];
    }
}
-(void) JumpButtonUp
{
    JumpButtonDown = false;
}
-(void) startRunEffect
{
    runEffect = [[SimpleAudioEngine sharedEngine]playLoopEffect:@"Run.caf"];
}
-(void) JumpUpdate
{
    if(Jumping ==true)
    {
        [self applyGravity];
        [self terminalVelocityUpdate];
    }
}
-(void) playerSwap
{
    if(canSwap)//if on the ground on a swappable platform
    {
        CCFlipY* flipy;
        if(!Swapped)
        {
            flipy = [CCFlipY actionWithFlipY:YES];
            self.position = ccp(position_.x, position_.y-[self height]);
            Swapped = true;
        }
        else
        {
            flipy = [CCFlipY actionWithFlipY:NO];
            Swapped = false;
            self.position = ccp(position_.x, position_.y+[self height]);
        }
        [[SimpleAudioEngine sharedEngine]playEffect:@"swap.caf"];
        [self runAction:flipy];
    }
}
-(void) applyGravity
{
    if(!Falling)
    {
        if(JumpButtonDown)
        {
            gravity = reducedGravity;
        }
        else
        {
            gravity = fullGravity;
        }
    }
    if(Falling)
    {
        gravity = reducedGravity;
    }
    if(Jumping)
    {
        if(Swapped)
        {
            YVelocity +=gravity;
        }
        else
        {
            YVelocity-=gravity;
        }
        if((Swapped &&YVelocity>0)||(!Swapped&&YVelocity<0))
        {
            Falling = true;
        }
    }
}
-(void) offPlatform: (NSMutableArray*) platforms unswappableplats: (NSMutableArray*) unswappableplatforms
{
    for(int i = 0; i<unswappableplatforms.count;i++)
    {
        if([[unswappableplatforms objectAtIndex:i]stopSprite:self])//if you are on an unswapable platform you simply cannot swap no mattter what
        {
            if(Jumping)
            {
                [self stopAllActions];
                [[SimpleAudioEngine sharedEngine] playEffect:@"fall.caf"];
                runEffect =  [[SimpleAudioEngine sharedEngine]playLoopEffect:@"Run.caf"];
                [self runAction:walkAction]; 
            }
            [self playerStopJump];
            Jumping = false;
            Falling = false;
            canSwap = false;
            JumpButtonDown = false;
            return;
        }
    }
    for(int i = 0; i<platforms.count;i++)
    {
        if([[platforms objectAtIndex:i]stopSprite:self])
        {
            if(Jumping)
            {
                
                [self stopAllActions];
                [[SimpleAudioEngine sharedEngine] playEffect:@"fall.caf"];
                runEffect =  [[SimpleAudioEngine sharedEngine]playLoopEffect:@"Run.caf"];
                [self runAction:walkAction]; 
            }
            [self playerStopJump];
            Jumping = false;
            Falling = false;
            canSwap = true;//if on a normal platform you can swap(make unswappable platforms check first>
            JumpButtonDown = false;
            return;
        }
    }
    if(!Jumping)
    {
        [self stopAllActions];
        [self runAction:jumpAction];
        [[SimpleAudioEngine sharedEngine]stopEffect:runEffect];
    }
    Jumping = true;
    canSwap = false;
    if((Swapped&&YVelocity>0)||(!Swapped&&YVelocity<0))
    {
        Falling = true;
    }
}
-(bool) getFalling
{
    return Falling;
}
-(bool) getJumping
{
    return Jumping;
}
-(void) terminalVelocityUpdate
{
    if(Swapped&&YVelocity>terminalVelocity)
    {
        YVelocity = terminalVelocity;
    }
    else if(!Swapped&&YVelocity<-terminalVelocity)
    {
        YVelocity = -terminalVelocity;
    }
}
-(bool) isDead: (NSMutableArray*) spikes sawarray: (NSMutableArray*) saws
{
    for(int i = 0; i<spikes.count;i++)
    {
        if([self Intersects:[spikes objectAtIndex:i]])
        {
                Dead = true;
                [self stopAllActions];
                [self runAction:dieAction];
                    [[SimpleAudioEngine sharedEngine]stopEffect:runEffect];
                [[SimpleAudioEngine sharedEngine] playEffect:@"squish.caf"];
               return true;
        }
    }
    for(int i = 0; i<saws.count;i++)
    {
        if([self IntersectsIgnoreSwapSwappableSprite:[saws objectAtIndex:i]])
        {
            Dead = true;
            [self stopAllActions];
            [self runAction:dieAction];
                    [[SimpleAudioEngine sharedEngine]stopEffect:runEffect];
            [[SimpleAudioEngine sharedEngine] playEffect:@"squish.caf"];
            return true;
        }
    }
    if((Swapped && position_.y>370)||(!Swapped && position_.y<-50))
    {
        Dead = true;
        [self stopAllActions];
        return true;
    }
    return false;
}
-(bool) isWinner: (FinishLine*) finish
{
    if([self IntersectsIgnoreSwap:finish])
    {
        [[SimpleAudioEngine sharedEngine]stopEffect:runEffect];
        return true;
    }
    return false;
}
-(void) spikesOnOtherSide: (NSMutableArray*) spikes saw: (NSMutableArray*) saws
{
    if(canSwap)//no point unless you can swap
    {
        CGRect nextRect = [self boundingBox];//the rect you would have if you swapped
        if(Swapped)
        {
            nextRect.origin.y+=[self height];
        }
        else
        {
            nextRect.origin.y-=[self height];
        }
        for(int i = 0; i<spikes.count;i++)
        {
            if(CGRectIntersectsRect(nextRect, [[spikes objectAtIndex:i]boundingBox]))
            {
                canSwap = false;
                return;
            }
        }
        for(int i = 0; i<saws.count;i++)
        {
            if(CGRectIntersectsRect(nextRect, [[saws objectAtIndex:i]newboundingBox]))
            {
                canSwap = false;
                return;
            }
        }
    }
}
- (void) dealloc
{	
	// don't forget to call "super dealloc"
    Dead = false;
    [super dealloc];
}
@end
