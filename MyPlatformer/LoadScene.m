//
//  LoadScene.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadScene.h"
#import "MainMenuScene.h"
@implementation LoadScene
-(id) init
{
    if((self = [super init]))
    {
        CCSprite* Title = [[CCSprite alloc] initWithFile:@"Bounding_Blob_Text.png"];
        CCSprite* TitleScreen = [[CCSprite alloc]initWithFile:@"Title_Screen.png"];
        TitleScreen.position = ccp(240, 160);
        Title.position = ccp(240, 275);
        [Title setScale:1.6];
        [self addChild:TitleScreen z:-1];
        [self addChild:Title];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GameAnim.plist"];//load all objects
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GrassBGAnim.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"GrassMIDAnim.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CityBGAnim.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CityMIDAnim.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MarsBGAnim.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MarsMIDAnim.plist"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"jump.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"click.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"cheer.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"fall.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pop.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Run.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Saw.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"squish.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"star1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"star2.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"3star.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"swap.caf"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = .1;
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Section1Loop.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Section2Loop.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Section3Loop.mp3"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"MainMenuLoop.mp3"];
        [SimpleAudioEngine sharedEngine].effectsVolume = .5;
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MainMenuLoop.mp3" loop:YES];
        [self schedule:@selector(changeScene)];
    }
    return self;
}
-(void) changeScene
{
     [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];//scene change
}
@end
