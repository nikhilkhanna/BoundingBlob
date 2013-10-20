//
//  SlideHolder.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SlideHolder.h"
ButtonSlide* b1;
ButtonSlide* b2;
ButtonSlide* b3;
int level;
@implementation SlideHolder
-(id) initWithArray: (NSMutableArray*) slides
{
    if((self = [super init]))
    {
        level = 0;
        b1 = [slides objectAtIndex:0];
        b1.position = ccp(0,0);
        b2 = [slides objectAtIndex:1];
        b2.position = ccp(420, 0);
        b3 = [slides objectAtIndex:2];
        b3.position = ccp(840, 0);
        self.position = ccp(240, 150);
        [self addChild:b1];
        [self addChild:b2];
        [self addChild:b3];
    [self schedule:@selector(Update)];
    }
    return self;
}
-(void) Update
{
    if([b1 currentLevelNumber]!=0)
        level = [b1 currentLevelNumber];
    else if([b2 currentLevelNumber]!=0)
        level = [b2 currentLevelNumber];
    else if([b3 currentLevelNumber]!=0)
        level = [b3 currentLevelNumber];
}
-(int) level
{
    return level;
}
-(void) dealloc
{
    [self removeAllChildrenWithCleanup:true];
    level = 0;
    [b1 release];
    [b2 release];
    [b3 release];
    b1 = nil;
    b2 = nil;
    b3 = nil;
    [super dealloc];
}
@end
