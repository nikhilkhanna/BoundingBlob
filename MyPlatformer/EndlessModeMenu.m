//
//  EndlessModeMenu.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "EndlessModeMenu.h"
#import "SwappableCCSprite.h"
#import "EndlessScene.h"
#import "MainMenuScene.h"
#import "SimpleAudioEngine.h"
@implementation EndlessModeMenu
@synthesize adWhirlView;
CCMenu* menu;
-(id) init
{
    if(self = [super init])
    {
        SwappableCCSprite* backgroundSprite = [[SwappableCCSprite alloc] fileInitWithFrame:@"City_MID_3.png" swapvalue:false];
        SwappableCCSprite* farbackgroundSprite = [[SwappableCCSprite alloc]fileInitWithFrame:@"City_BG_2.png"swapvalue:false];
        [self addChild:farbackgroundSprite];
        [self addChild:backgroundSprite];
        farbackgroundSprite.position=ccp(240, 160);
        backgroundSprite.position=ccp(240,[backgroundSprite halfheight]);
        CCMenuItem* Back = [CCMenuItemImage itemFromNormalImage:@"Back_Arrow.png" selectedImage:@"Back_Arrow_Touch.png"target:self selector:@selector(goBack)];
        Back.position = ccp(-210, 125);
        CCMenuItem* Play = [CCMenuItemImage itemFromNormalImage:@"Play.png" selectedImage:@"Play_Touch.png"  target:self selector:@selector(play)];
        Play.position = ccp(0, 0);
        [Play setScaleX:2];
        [Play setScaleY:2];
        NSString* highScoreString = [NSString stringWithFormat:@"High Score:%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]];
        CCLabelTTF* highScore = [CCLabelTTF labelWithString:highScoreString fontName:@"Arial" fontSize:30];
        highScore.position = ccp(240, 250);
        [self addChild:highScore z:1];
        menu = [CCMenu menuWithItems: Back, Play,nil];
        [self addChild:menu z:1];
    }
    return self;
}
-(void) play
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    [[CCDirector sharedDirector] replaceScene:[[EndlessScene alloc] init]];
}
-(void) goBack
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    [self removeAllChildrenWithCleanup:true];
    [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];//scene change 
}
-(void) adWhirlWillPresentFullScreenModal
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    [[CCDirector sharedDirector] pause];
}
-(void) adWhirlDidDismissFullScreenModal
{
    [[SimpleAudioEngine sharedEngine]resumeBackgroundMusic];
    [[CCDirector sharedDirector]resume];
}
-(NSString *) adWhirlApplicationKey
{
    return @"0fbcc132e203407bb596f3d2067167f9";
}
-(UIViewController *)viewControllerForPresentingModalView
{
    return viewController;
}
-(void)adjustAdSize
{
    [UIView beginAnimations:@"AdResize" context:nil];
    [UIView setAnimationDuration:0.2];
    CGSize adSize = [adWhirlView actualAdSize];
    CGRect newFrame = adWhirlView.frame;
    newFrame.size.height = adSize.height;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    newFrame.size.width = winSize.width;
    newFrame.origin.x = (self.adWhirlView.bounds.size.width-adSize.width)/2;
    newFrame.origin.y = (winSize.height-adSize.height);
    adWhirlView.frame = newFrame;
    [UIView commitAnimations];
}
-(void) adWhirlDidReceiveAd:(AdWhirlView *)adWhirlVieww//watch the typos
{
    [adWhirlView rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
    [self adjustAdSize];
}
-(void)onEnter {
    //1
    viewController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] viewController];
    //2
    self.adWhirlView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    //3
    self.adWhirlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    //4
    [adWhirlView updateAdWhirlConfig];
    //5
	CGSize adSize = [adWhirlView actualAdSize];
    //6
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //7
	self.adWhirlView.frame = CGRectMake((winSize.width/2)-(adSize.width/2),winSize.height-adSize.height,winSize.width,adSize.height);
    //8
	self.adWhirlView.clipsToBounds = YES;
    //9
    [viewController.view addSubview:adWhirlView];
    //10
    [viewController.view bringSubviewToFront:adWhirlView];
    //11
    [super onEnter];
}

-(void)onExit {
    if (adWhirlView) {
        [adWhirlView removeFromSuperview];
        [adWhirlView replaceBannerViewWith:nil];
        [adWhirlView ignoreNewAdRequests];
        [adWhirlView setDelegate:nil];
        self.adWhirlView = nil;
    }
    [super onExit];
}
-(void) dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    [super dealloc];
}
@end