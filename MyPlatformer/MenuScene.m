//
//  MenuScene.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/30/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "MenuScene.h"
#import "MainMenuScene.h"
#import "LevelSelect.h"
#import "LevelScene.h"
LevelSelect* levelSelect;
int levelToLoad = 0;
@implementation MenuScene
-(id) init: (int) levelnum
{
    if(self = [super init])
    {
        levelToLoad = 0;
        levelSelect = [[LevelSelect alloc]init:levelnum];
        [self addChild:levelSelect];
        [self schedule:@selector(Update)];
    }
    return self;
}
-(void)Update
{
    levelToLoad = [levelSelect levelNumber];//moving it up so that the level can get into app delegate and go back down through the Level Scene so it knows what to load
    if(levelToLoad != 0)//if the scene has been chosen
    {
        [self removeAllChildrenWithCleanup:YES];
        [levelSelect release];
        [self unschedule:@selector(Update)];
        [[CCDirector sharedDirector] replaceScene:[[LevelScene alloc] init:levelToLoad]];//scene change
    }
    else if([levelSelect back])
    {
        [self goBack];
    }
}
-(int) LevelNumber
{
    return levelToLoad;
}
-(void) goBack
{
    [self removeAllChildrenWithCleanup:true];
    [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];//scene change 
}
-(void)dealloc
{
    [self removeAllChildrenWithCleanup:true];
    [self unschedule:@selector(Update)];
    [levelSelect release];
    [super dealloc];
}
@end
