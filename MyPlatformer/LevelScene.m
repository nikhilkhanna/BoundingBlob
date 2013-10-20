//
//  LevelScene.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "LevelScene.h"
#import "MenuScene.h"
#import "WinLayer.h"
#import "Playtomic.h"
#import "SimpleAudioEngine.h"
int currentlevelnumber = 1;
int previousLevelStarNumber = 0;
const int MaxLevelNumber = 45;//highest level there is//change later
LevelLayer* level;
WinLayer* win;
enum State {Level, Win};
enum State currentState = Level;
@implementation LevelScene//will handle the running and changing of levels including next level screens until we are @ main menu
-(id) init: (int) levelnumber
{
    if((self = [super init]))
    {
        currentlevelnumber = levelnumber;
        [self newLevel];
        if(levelnumber<16)
        {
            [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"Section1Loop.mp3" loop:true];
        }
        else if (levelnumber<31) 
        {
            [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"Section2Loop.mp3" loop:true];
        }
        else
        {
            [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"Section3Loop.mp3" loop:true];
        }
        [self schedule:@selector(Update)];
    }
    return self;
}
-(void) pauseGame
{
    if(currentState==Level)
    {
        if(![level paused])
        {
            [level Pause];
        }
    }
}
-(void) Update
{
    if(currentState==Level)//this gets the nubmer of the stars from a level deletes it, it increments level number, and makes a win screen
    {
        if([level playerWin])
        {
            previousLevelStarNumber = [level starsCollected];//getting the number of stars here is where i save it as well
            [[Playtomic Log]levelCounterMetricName:@"LevelCompete" andLevelNumber:currentlevelnumber andUnique:NO];
            [[Playtomic Log]customMetricName:[NSString stringWithFormat:@"starscollected:%d", previousLevelStarNumber] andGroup:[NSString stringWithFormat:@"level:%d", currentlevelnumber] andUnique:NO];
            currentlevelnumber++;//incrementing level number
            [self newEndScreen];//making a new end screen
        }
        else if([level menu])
        {
            [self emptyScene];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
            [[CCDirector sharedDirector]replaceScene:[[MenuScene alloc]init:currentlevelnumber]];
        }
    }
    if(currentState==Win)
    {
        if([win goToNext])
        {
            if(currentlevelnumber>MaxLevelNumber)
            {
                [self emptyScene];
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
                [[CCDirector sharedDirector]replaceScene:[[MenuScene alloc]init:currentlevelnumber]];
            }
            else if ((currentlevelnumber==16&&[self numtotalStars]<30)||(currentlevelnumber==31&&[self numtotalStars]<60))
            {
                [self emptyScene];
                [[CCDirector sharedDirector]replaceScene:[[MenuScene alloc]init:currentlevelnumber]];
            }
            else 
            {
                [self removeChild:win cleanup:YES];
                [win release];
                [self newLevel];
            }
        }
        else if([win goToReplay])
        {
            [self removeChild:win cleanup:YES];
            [win release];
            currentlevelnumber--;
            [self newLevel];
        }
        else if([win goToLevelSelect])//if menu button is hit
        {
            [self emptyScene];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
            [[CCDirector sharedDirector]replaceScene:[[MenuScene alloc]init:currentlevelnumber]];
        }
    }
}
-(void) newLevel
{
    if(currentlevelnumber==16)
    {
        [[SimpleAudioEngine sharedEngine]stopBackgroundMusic ];
        [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"Section2Loop.mp3" loop:true];
    }
    else if (currentlevelnumber==31)
    {
        [[SimpleAudioEngine sharedEngine]stopBackgroundMusic ];
        [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"Section3Loop.mp3" loop:true];
    }
    level = [[LevelLayer alloc] levelinit:currentlevelnumber];
    [self addChild:level];
    currentState = Level;
}
-(void) newEndScreen
{
    win = [[WinLayer alloc]WinInit:previousLevelStarNumber maxlevel:MaxLevelNumber current:currentlevelnumber];
    [self addChild:win];
    win.position = ccp(win.position.x, win.position.y+360);
    id winAction = [CCMoveTo actionWithDuration:.75 position:ccp(0, 0)];
    id deleteLevelAction = [CCCallFunc actionWithTarget:self selector:@selector(deleteLevel)];
    id winSequence = [CCSequence actions:winAction,deleteLevelAction,[CCCallFunc actionWithTarget:win selector:@selector(makeStarHolder)], nil];
    currentState = Win;
    [win runAction:winSequence];
}
-(void) deleteLevel
{
    [self removeChild:level cleanup:YES];
    [level release];//removing level
}
-(int) numtotalStars
{
    int totalStarsCounter = 0;
    for(int i = 1; i<46;i++)
    {
        int levelStars = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"Level%d",i]];
        if(levelStars>0)
        {
            totalStarsCounter+=levelStars;//adding the stars on a sepcific level to the counter
        }
    }
    return totalStarsCounter;
}                   
-(void) emptyScene
{
    [self removeAllChildrenWithCleanup:YES];
    [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
    if(currentState==Level)
    {
        [level release];
        level = nil;
    }
    else 
    {
        [win release];
        win = nil;
    }
    [self unschedule:@selector(Update)];
}
- (void) dealloc
{	
    [self emptyScene];
	[super dealloc];
}
@end
