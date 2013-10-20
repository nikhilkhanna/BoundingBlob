//
//  Portal.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/19/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Portal.h"
#import "Platform.h"
#import "Player.h"
@implementation Portal
bool first;
-(id) initwithcoordinates: (int) x1 p1: (Platform*) plat1 x2: (int) x2 p2: (Platform*) plat2 first: (bool) isFirst
{
    NSString* portal1name;
    NSString* portal2name;
    if(isFirst)
    {
        portal1name = @"Blue_Green_Portal_0.png";
        portal2name = @"Blue_Red_0.png";
    }
    else 
    {
        portal1name = @"Purple_Green_0.png";
        portal2name = @"Purple_Red_0.png";
    }
    if((self=[super fileInitWithFrame:portal1name swapvalue:false]))
    {
        first = isFirst;
        self.position = ccp(x1, plat1.position.y);
        portal2 = [[SwappableCCSprite alloc] fileInitWithFrame:portal2name swapvalue:false];
        self.portal2.position=ccp(x2,plat2.position.y);
        [self makeAnimations];
        [self setScale:1.3];
        [portal2 setScale:1.3];
        [self runAction:self->Portal1animation];
        [portal2 runAction:self->Portal2animation];
    }
    return self;
}
-(id) initwithxycoordinates: (int) x1 y1: (int) y1 x2: (int) x2 p2: (Platform*) plat2 first: (bool) isFirst
{
    NSString* portal1name;
    NSString* portal2name;
    if(isFirst)
    {
        portal1name = @"Blue_Green_Portal_0.png";
        portal2name = @"Blue_Red_0.png";
    }
    else 
    {
        portal1name = @"Purple_Green_0.png";
        portal2name = @"Purple_Red_0.png";
    }
    if((self=[super fileInitWithFrame:portal1name swapvalue:false]))
    {
        first = isFirst;
        self.position = ccp(x1, y1);
        portal2 = [[SwappableCCSprite alloc] fileInitWithFrame:portal2name swapvalue:false];
        self.portal2.position=ccp(x2,plat2.position.y);
        [self makeAnimations];
        [self setScale:1.3];
        [portal2 setScale:1.3];
        [self runAction:self->Portal1animation];
        [portal2 runAction:self->Portal2animation];
    }
    return self;
}
-(CGRect) newboundingBox
{
    return CGRectMake(self.position.x-12.5, self.position.y-25, 25, 50);
}
-(void) makeAnimations
{
    NSMutableArray *portalAnimFrames = [NSMutableArray array];
    if(first)
    {
        for(int i = 0; i <= 23; ++i) 
        {
            [portalAnimFrames addObject:
            [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
            [NSString stringWithFormat:@"Blue_Green_Portal_%d.png", i]]];
        }
    }
    else
    {
        for(int i = 0; i <= 23; ++i) 
        {
            [portalAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Purple_Green_%d.png", i]]];
        }
    }
    CCAnimation* portalAnimation = [CCAnimation animationWithFrames:portalAnimFrames delay:0.08f];
    self ->Portal1animation = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:portalAnimation restoreOriginalFrame:NO]]; 
    [self->Portal1animation retain];
    //second animation
    NSMutableArray *portal2AnimFrames = [NSMutableArray array];
    if(first)
    {
        for(int i = 0; i <= 23; ++i) 
        {
            [portal2AnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Blue_Red_%d.png", i]]];
        }
    }
    else
    {
        for(int i = 0; i <= 23; ++i) 
        {
            [portal2AnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"Purple_Red_%d.png", i]]];
        }
    }
    CCAnimation* secondPortalAnimation = [CCAnimation animationWithFrames:portal2AnimFrames delay:0.08f];
    self ->Portal2animation = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:secondPortalAnimation restoreOriginalFrame:NO]]; 
    [self->Portal2animation retain];
}
-(void) Update
{
    [super Update];
    [portal2 Update];
}
-(SwappableCCSprite*) portal2
{
    return portal2;
}
-(bool) teleportPlayer: (Player*) p
{
    if([self IntersectsIgnoreSwapSwappableSprite:p])
    {
        if([p isSwapped])
        {
            p.position = ccp(self.portal2.position.x, self.portal2.position.y-[p halfheight]);
        }
        else 
        {
             p.position = ccp(self.portal2.position.x, self.portal2.position.y+[p halfheight]);
        }
        [[SimpleAudioEngine sharedEngine] playEffect:@"pop.caf"];
        return true;
    }
    return false;
}
-(void) updateCameraPosition: (int) correctionFactor
{
    self.position = ccp(self.position.x+correctionFactor, self.position.y);
    portal2.position = ccp(portal2.position.x+correctionFactor, portal2.position.y);
}
-(void) dealloc
{
    [self removeAllChildrenWithCleanup:true];
    [portal2 release];
    portal2 = nil;
    [super dealloc];
}
@end
