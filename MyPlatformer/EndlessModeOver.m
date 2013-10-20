//
//  EndlessModeOver.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 8/2/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "EndlessModeOver.h"
#import "SimpleAudioEngine.h"
@implementation EndlessModeOver
@synthesize adWhirlView;
bool Menu;
bool Replay;
CCMenu* Mymenu;
CCLabelTTF* currentScore;
CCLabelTTF* highScore;
-(id) init: (int) score
{
    if((self = [super initWithColor:ccc4(8, 146, 208, 255)]))
    {
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]<score)
        {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highScore"];
        }
        NSString* myString = [NSString stringWithFormat:@"Score:%d", score];
        currentScore = [CCLabelTTF labelWithString:myString fontName:@"Arial" fontSize:30];
        currentScore.position = ccp(240, 270);
        [self addChild:currentScore z:999];
        NSString* highScoreString = [NSString stringWithFormat:@"High Score:%d", [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]];
        highScore = [CCLabelTTF labelWithString:highScoreString fontName:@"Arial" fontSize:30];
        highScore.position = ccp(240, 210);
        [self addChild:highScore z:999];
        Menu = false;
        Replay = false;
        [self makeButtons];
    }
    return self;
}
-(bool) goToMenu
{
    return Menu;
}
-(bool) goToReplay
{
    return Replay;
}
-(void) makeButtons//makes the menu buttons (might change later)
{
    CCMenuItemImage * MenuButton = [CCMenuItemImage itemFromNormalImage:@"Main_Menu.png" selectedImage:@"Main_Menu_Touch.png" target:self selector: @selector(menu)];
    MenuButton.position = ccp(125, -50);
    [MenuButton setScaleX:1.5];
    [MenuButton setScaleY:1.5];
    CCMenuItemImage * ReplayButton = [CCMenuItemImage itemFromNormalImage:@"Replay.png" selectedImage:@"Replay_Touch.png" target:self selector: @selector(replay)];
    ReplayButton.position = ccp(-125, -50);
    [ReplayButton setScaleX:1.5];
    [ReplayButton setScaleY:1.5];
    Mymenu = [CCMenu menuWithItems:MenuButton, ReplayButton, nil];
    [self addChild:Mymenu];
}
-(void) menu
{
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    Menu = true;
}
-(void) replay
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    Replay = true;
}
-(void) dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    [self removeAllChildrenWithCleanup:true];
    Menu = false;
    Replay = false;
    [super dealloc];
}
//adwhirl
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

@end
