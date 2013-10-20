//
//  StarHolder.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarHolder.h"

@implementation StarHolder
-(id)initWithFrame
{
    if((self=[super fileInitWithFrame:@"Holder_Ani_1.png" swapvalue:false]))
    {
        self.position= ccp(43,305);
        [self makeAnimations];
    }
    return self;
}
-(void) makeAnimations
{
    //one
    NSMutableArray *first = [NSMutableArray array];
    for(int i = 1; i <= 18; ++i) 
    {
        [first addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Holder_Ani_%d.png", i]]];
    }
    CCAnimation* firstAnimation = [CCAnimation animationWithFrames:first delay:0.05f];
    self ->noneToOne = [CCAnimate actionWithAnimation:firstAnimation restoreOriginalFrame:NO]; 
    [self->noneToOne retain];
    //two
    NSMutableArray *second = [NSMutableArray array];
    for(int i = 1; i <= 18; ++i) 
    {
        [second addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Holder_Ani_2_%d.png", i]]];
    }
    CCAnimation* secondAnimation = [CCAnimation animationWithFrames:second delay:0.05f];
    self ->oneToTwo = [CCAnimate actionWithAnimation:secondAnimation restoreOriginalFrame:NO]; 
    [self->oneToTwo retain];
    //three
    NSMutableArray *third = [NSMutableArray array];
    for(int i = 1; i <= 18; ++i) 
    {
        [third addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"Holder_Ani_3_%d.png", i]]];
    }
    CCAnimation* thirdAnimation = [CCAnimation animationWithFrames:third delay:0.05f];
    self ->twoToThree = [CCAnimate actionWithAnimation:thirdAnimation restoreOriginalFrame:NO]; 
    [self->twoToThree retain];
}
-(void) Animate: (int) numStars
{
    if(numStars==1)
    {
        [self runAction:noneToOne];
    }
    else if(numStars==2) 
    {
        [self runAction:oneToTwo];
    }
    else if (numStars==3)
    {
        [self runAction:twoToThree];
    }
}
-(void) dealloc
{
    [self stopAllActions];
    [super dealloc];
}
@end
