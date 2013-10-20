//
//  Saw.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/8/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Saw.h"
#import "Math.h"
bool big;
@implementation Saw
-(id) initwithpoints: (int) x1 y: (int) y1 nextx:(int) x2 nexty: (int) y2 speed: (float) mySpeed big: (bool) isBig
{
    playingLoop = false;
    NSString* s; 
    big = isBig;
    if(isBig)
    {
        s = @"LargeSaw1.png";
    }
    else
    {
        s = @"SmallSaw1.png";
    }
    if((self = [super fileInitWithFrame:s swapvalue:false]))
    {
        big = isBig;
        point1 = ccp(x1, y1);
        point2 = ccp(x2, y2);
        speed = mySpeed;
        goingtopoint2 = true;
        self.position = point1;
        [self makeAnimation];
    }
    return self;
}
-(ALuint) getSpinSound
{
    return spinSound;
}
-(void) stopSpinSound
{
    [[SimpleAudioEngine sharedEngine]stopEffect:spinSound];
    playingLoop = false;
}
-(void) makeAnimation
{
    if(big)
    {
        NSMutableArray *largeSpinAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 12; ++i) 
        {
            [largeSpinAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"LargeSaw%d.png", i]]];
        }
        CCAnimation* largeSawTurnAnimation = [CCAnimation animationWithFrames:largeSpinAnimFrames delay:0.05f];
        self->sawSpinAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:largeSawTurnAnimation restoreOriginalFrame:NO]]; 
    }
    else
    {
        NSMutableArray *smallSpinAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 12; ++i) 
        {
            [smallSpinAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"SmallSaw%d.png", i]]];
        }
        CCAnimation* smallSawTurnAnimation = [CCAnimation animationWithFrames:smallSpinAnimFrames delay:0.05f];
        self->sawSpinAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:smallSawTurnAnimation restoreOriginalFrame:NO]];
        [self->sawSpinAction retain];
    }
}
-(void) spinAction
{
    [self runAction:self->sawSpinAction];
}
-(bool) isOffScreen
{
    if(point1.x<-[self width]&&point2.x<-[self width])
    {
        return true;
    }
    return false;
}
-(bool) isBig
{
    return big;
}
-(void) Update
{
    //updating the points
    point1.x-=3;
    point2.x-=3;
    [super Update];//moves sprite to left
    if([self isOffScreen])
    {
        self.visible = false;
    }
    [self move];
    if([self isInView])
    {
        if(!playingLoop)
        {
            playingLoop = true;
            spinSound = [[SimpleAudioEngine sharedEngine]playLoopEffect:@"Saw.caf"];
        }
    }
    else
    {
        [[SimpleAudioEngine sharedEngine] stopEffect:spinSound];
        playingLoop = false;
    }
}
-(void) deadUpdate
{
    [self move]; 
}
-(void) EndlessUpdate
{
    //updating the points
    point1.x-=3;
    point2.x-=3;
    [super VisiblityUpdate];//moves sprite to left
    [self move];
}
-(void)move
{
    if(goingtopoint2)
    {
        if(sqrtf(powf(point2.x-self.position.x, 2)+powf(point2.y-self.position.y, 2))<=speed)//if the distance between point 2 and position is less than the speed
        {
            goingtopoint2 = false;
            self.position = point2;
            return;
        }
        CGFloat x = point2.x-point1.x;
        CGFloat y = point2.y-point1.y;
        CGPoint unitvector = ccp(x/sqrtf((x*x)+(y*y)), y/sqrtf((x*x)+(y*y)));
        CGPoint finalvector = ccp((unitvector.x*speed), (unitvector.y*speed));//the vector to travel this frame
        self.position = ccp(self.position.x+finalvector.x, self.position.y+finalvector.y);
    }
    else
    {
        if(sqrtf(powf(point1.x-self.position.x, 2)+powf(point1.y-self.position.y, 2))<=speed)//if the distance between point 1 and position is less than the speed
        {
            goingtopoint2 = true;
            self.position = point1;
            return;
        }
        CGFloat x = point1.x-point2.x;
        CGFloat y = point1.y-point2.y;
        CGPoint unitvector = ccp(x/sqrtf((x*x)+(y*y)), y/sqrtf((x*x)+(y*y)));//unit vector 
        CGPoint finalvector = ccp(unitvector.x*speed, unitvector.y*speed);//the vector to travel this frame
        self.position = ccp(self.position.x+finalvector.x, self.position.y+finalvector.y);//adding it to position
    }
}
-(CGPoint) point1
{
    return point1;
}
-(CGPoint) point2
{
    return point2;
}
-(void) dealloc
{
    [[SimpleAudioEngine sharedEngine] stopEffect:spinSound];
    [self stopAllActions];
    [super dealloc];
}
-(CGRect) newboundingBox
{
    if(big)
    return CGRectMake(self.position.x-12.5, self.position.y-12.5, 30 , 30);
    else 
    {
        return CGRectMake(self.position.x-5, self.position.y-5, 10, 10);
    }
}
-(void) updateCameraPosition: (int) correctionFactor
{
    point1.x+=correctionFactor;
    point2.x+=correctionFactor;
    self.position = ccp(self.position.x+correctionFactor, self.position.y);
}
@end
