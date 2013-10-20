//
//  Star.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Star.h"

@implementation Star
-(id) initwithcoordinates: (int) x ycoord: (int) y swapvalue:(bool) swap
{
    if((self=[super fileInitWithFrame:@"star1.png" swapvalue:swap]))
    {
        isDeleted = false;
        self.position= ccp(x,y);
        [self makeAnimations];
    }
    return self;
}
-(void) makeAnimations
{
    NSMutableArray *turnanimframes = [NSMutableArray array];
    for(int i = 1; i <= 19; ++i) 
    {
        [turnanimframes addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"star%d.png", i]]];
    }
    CCAnimation* starTurnAnimation = [CCAnimation animationWithFrames:turnanimframes delay:0.08f];
    self ->starTurnAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:starTurnAnimation restoreOriginalFrame:NO]]; 
    [self->starTurnAction retain];
    //dissappear animation
    NSMutableArray *dissappearanimframes = [NSMutableArray array];
    for(int i = 1; i <= 35; ++i) 
    {
        [dissappearanimframes addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"star_dust_out%d.png", i]]];
    }
    self->starDeleteAction = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:dissappearanimframes delay:0.014f]restoreOriginalFrame:NO];
    [self->starDeleteAction retain];
}
-(void) turn
{
    [self runAction:self->starTurnAction];
}
-(void) dissappear
{
    [self runAction:self->starDeleteAction];
}
-(void) selfdelete
{
    isDeleted = true;
}
-(bool) Deleted
{
    return isDeleted;
}
- (void) dealloc
{	
	// don't forget to call "super dealloc"
    [starDeleteAction release];
    [starTurnAction release];
    isDeleted = false;
    [self setVisible:false];
    [self stopAllActions];
	[super dealloc];
}
@end
