//
//  MainMenuScene.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "MainMenuScene.h"
#import "MenuScene.h"
#import "EndlessModeMenu.h"
#import "SimpleAudioEngine.h"
@implementation MainMenuScene
CCMenu* menu;
-(id) init
{
    if(self = [super init])
    {
        CCSprite* Title = [[CCSprite alloc] initWithFile:@"Bounding_Blob_Text.png"];
        CCSprite* TitleScreen = [[CCSprite alloc]initWithFile:@"Title_Screen.png"];
        TitleScreen.position = ccp(240, 160);
        Title.position = ccp(240, 275);
        [Title setScale:1.6];
        [self addChild:TitleScreen z:-1];
        [self addChild:Title];
        CCMenuItem* LevelSelect = [CCMenuItemImage itemFromNormalImage:@"Normal.png" selectedImage:@"Normal_Touch.png"target:self selector:@selector(goToLevelSelect)];
        LevelSelect.position = ccp(-125, -100);
        [LevelSelect setScaleX:1.5];
        [LevelSelect setScaleY:1.5];
        CCMenuItem* Endless = [CCMenuItemImage itemFromNormalImage:@"Endless.png" selectedImage:@"Endless_Touch.png"  target:self selector:@selector(goToEndless)];
        Endless.position = ccp(125, -100);
        [Endless setScaleX:1.5];
        [Endless setScaleY:1.5];
        menu = [CCMenu menuWithItems: LevelSelect, Endless,nil];
        [self addChild:menu];
    }
    return self;
}
-(void) goToLevelSelect
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    [self removeAllChildrenWithCleanup:true];
    [[CCDirector sharedDirector] replaceScene:[[MenuScene alloc] init:1]];//scene change
}
-(void) goToEndless
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    [self removeAllChildrenWithCleanup:true];
    [[CCDirector sharedDirector] replaceScene:[[EndlessModeMenu alloc] init]];//scene change
}
@end
