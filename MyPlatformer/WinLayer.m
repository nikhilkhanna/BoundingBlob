//
//  WinLayer.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/30/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "WinLayer.h"
#import "StarHolder.h"
#import "SimpleAudioEngine.h"
CCMenu* menu;
CCLabelTTF* levelLabel;
StarHolder* s;
bool Next;
bool LevelSelect;
bool Replay;
int maxLevel;
int nextLevel;
int numStars;
@implementation WinLayer
@synthesize adWhirlView;
-(id) WinInit: (int) starscollected maxlevel:(int) max current: (int) currentLevel;
{
    if(self = [super initWithColor:ccc4(8, 146, 208, 255)])
    {
        numStars = starscollected;
        maxLevel = max;
        nextLevel= currentLevel;//the level i have to load if next is pressed
        int previouslevel = currentLevel-1;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults integerForKey:[NSString stringWithFormat:@"Level%d", previouslevel]]<starscollected) //if the stars stored is less than the current stars
        {
            [defaults setInteger:starscollected forKey:[NSString stringWithFormat:@"Level%d",previouslevel]];//overwrite it 
        }
        [defaults synchronize];//synch it 
        NSString* levelString = [NSString stringWithFormat:@"Level %d", previouslevel];
        levelLabel = [CCLabelTTF labelWithString:levelString fontName:@"Times New Roman" fontSize:35];
        levelLabel.position = ccp(240, 290);
        [self addChild:levelLabel];
        levelLabel.color = ccc3(0, 0, 0);
       // [self makeButtons];
        Next = false;
        LevelSelect = false;
    }
    return self;
}
-(void) makeButtons//makes the menu buttons (might change later)
{
    CCMenuItemImage * MenuButton = [CCMenuItemImage itemFromNormalImage:@"Level_Select.png" selectedImage:@"Level_Select_Touch.png" target:self selector: @selector(menu)];
    MenuButton.position = ccp(125, -80);
    [MenuButton setScale:1.5];
    CCMenuItemImage * NextButton = [CCMenuItemImage itemFromNormalImage:@"Next.png" selectedImage:@"Next_Touch.png" target:self selector: @selector(nextLevel)];
    NextButton.position = ccp(-125, -80);
    [NextButton setScale:1.5];
    CCMenuItemImage * ReplayButton = [CCMenuItemImage itemFromNormalImage:@"Replay.png" selectedImage:@"Replay_Touch.png" target:self selector: @selector(replay)];
    ReplayButton.position = ccp(0, -10);
    [ReplayButton setScale:1.5];
    menu = [CCMenu menuWithItems:NextButton,MenuButton, ReplayButton, nil];
    [self addChild:menu];
}
-(void) makeStarHolder
{ 
    s = [[StarHolder alloc]initWithFrame];
    s.position = ccp(240, 225);
    [self addChild:s];
    [s setScaleX:1.75];
    [s setScaleY:1.75];
    if(numStars!= 0)
    {
        CCSequence* starSoundSequence;
        id HolderSequence;
        id makeButtonsAction = [CCCallFunc actionWithTarget:self selector:@selector(makeButtons)];
        if(numStars==1)
        {
            starSoundSequence = [CCSequence actions: 
                                 [CCCallBlock actionWithBlock:^(void)
                                  { 
                                      [[SimpleAudioEngine sharedEngine] playEffect:@"star1.caf"];
                                  }],
                                 nil];
            HolderSequence = [CCSequence actions:s->noneToOne,makeButtonsAction,nil];
        }
        else if (numStars==2)
        {
            starSoundSequence = [CCSequence actions: 
                                 [CCCallBlock actionWithBlock:^(void)
                                  { 
                                      [[SimpleAudioEngine sharedEngine] playEffect:@"star1.caf"];
                                  }],
                                 [CCDelayTime actionWithDuration:1],
                                 [CCCallBlock actionWithBlock:^(void)
                                  { 
                                      [[SimpleAudioEngine sharedEngine] playEffect:@"star2.caf"];
                                  }],
                                 nil];
            HolderSequence = [CCSequence actions:s->noneToOne,s->oneToTwo, makeButtonsAction,nil];
        }
        else
        {
            starSoundSequence = [CCSequence actions: 
                                    [CCCallBlock actionWithBlock:^(void)
                                     { 
                                         [[SimpleAudioEngine sharedEngine] playEffect:@"star1.caf"];
                                     }],
                                    [CCDelayTime actionWithDuration:1],
                                    [CCCallBlock actionWithBlock:^(void)
                                     { 
                                         [[SimpleAudioEngine sharedEngine] playEffect:@"star2.caf"];
                                     }],
                                    [CCDelayTime actionWithDuration:1],
                                    [CCCallBlock actionWithBlock:^(void)
                                     { 
                                        [[SimpleAudioEngine sharedEngine] playEffect:@"3star.caf"];
                                     }],
                                    [CCDelayTime actionWithDuration:.5],
                                    [CCCallBlock actionWithBlock:^(void)
                                     { 
                                      [[SimpleAudioEngine sharedEngine] playEffect:@"cheer.caf"];
                                     }],
                                    nil];
            HolderSequence = [CCSequence actions:s->noneToOne, s->oneToTwo, s->twoToThree, makeButtonsAction,nil]; 
        }
        [self runAction:starSoundSequence];
        [s runAction:HolderSequence];
    }
    else
    {
        [self makeButtons];
    }
}
-(void) nextLevel
{
    if([self numberOfRunningActions]==0&&[s numberOfRunningActions]==0)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
        Next = true;//scene handles everything else
    }
}
-(void) menu
{
    if([self numberOfRunningActions]==0&&[s numberOfRunningActions]==0)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
        LevelSelect = true;//scene handles everything else
    }
}
-(void) replay
{
    if([self numberOfRunningActions]==0&&[s numberOfRunningActions]==0)
    {
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    Replay = true;
    }
}
-(bool) goToNext
{
    return Next;
}
-(bool) goToLevelSelect
{
    return LevelSelect;
}
-(bool) goToReplay
{
    return Replay;
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

-(void)dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    [self removeAllChildrenWithCleanup:true];
    [s release];
    s = nil;
    Next = false;
    Replay = false;
    LevelSelect = false;
    [super dealloc];
}
@end
