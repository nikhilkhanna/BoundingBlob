//
//  EndlessScene.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EndlessScene.h"
#import "EndlessLayer.h"
#import "EndlessModeMenu.h"
#import "EndlessModeOver.h"
#import "Player.h"
#import "SimpleAudioEngine.h"
@implementation EndlessScene
EndlessLayer* endless;
EndlessModeOver* lose;
int lastScore;
bool isEndless;
-(id) init
{
    if(self = [super init])
    {
        isEndless = true;
        int rand = arc4random()%3+1;
        NSString *myString = [NSString stringWithFormat:@"Section%dLoop.mp3",rand];
        [[SimpleAudioEngine sharedEngine]playBackgroundMusic:myString loop:true];
        [self newEndless];
        [self schedule:@selector(Update)];
    }
    return self;
}
-(void) newEndless
{
    endless = [[EndlessLayer alloc] init];
    isEndless = true;
    [self addChild:endless];
}
-(void) newLoss
{
    lose = [[EndlessModeOver alloc] init:lastScore];
    isEndless = false;
    [self addChild:lose];
}
-(void) pauseGame
{
    if(isEndless)
    {
        if(![endless paused])
        {
            [endless Pause];
        }
    }
}
-(void) Update
{
    if(isEndless)
    {
        if([endless menu])
        {
            [self emptyScene];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
            [[CCDirector sharedDirector]replaceScene:[[EndlessModeMenu alloc]init]];
        }
        else if([endless lost])
        {
            lastScore = [endless score];
            [self removeChild:endless cleanup:YES];
            [endless release];//removing level
            [self newLoss];//making a new end screen
            
        }
    }
    if(!isEndless)
    {
        if([lose goToMenu])
        {
            [self emptyScene];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
            [[CCDirector sharedDirector]replaceScene:[[EndlessModeMenu alloc]init]];
        }
        else if([lose goToReplay])
        {
            [self removeChild:lose cleanup:YES];
            [lose release];//removing level
            [self newEndless];//making a new end screen
        }
    }
}
-(void) emptyScene
{
    [self removeAllChildrenWithCleanup:true];
    if (isEndless)
    {
        [endless release];
    }
    else
    {
        [lose release];
    }
    [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
    endless = nil;
    lose = nil;
}
-(void) dealloc
{
    [self emptyScene];
    [super dealloc];
}
@end
