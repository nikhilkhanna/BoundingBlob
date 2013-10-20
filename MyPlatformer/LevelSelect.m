//
//  LevelSelect.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/30/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "LevelSelect.h"
#import "ButtonSlide.h"
#import "SlideHolder.h"
#import "SwappableCCSprite.h"
#import "SimpleAudioEngine.h"
int levelToPlay = 0; //the level that will be played, zero if the player is choosing still(used by menuscene)
const int numLevels = 45;//the last level ensure button image files are present first
CCMenu* menu;
NSMutableArray* slides;
SlideHolder* holder;
int previousTouchX;
int currentTouchX;
int targetX;
int initialHolderX;
bool goingToTarget;
bool Back;
SwappableCCSprite* mg1;
SwappableCCSprite* bg1;
SwappableCCSprite* mg2;
SwappableCCSprite* bg2;
SwappableCCSprite* mg3;
SwappableCCSprite* bg3;
CCSprite* arrow1;
CCSprite* arrow2;
@implementation LevelSelect
@synthesize adWhirlView;
-(id) init: (int) initlevelnum
{
    levelToPlay = 0;
    if(self = [super init])
    {
        [self setIsTouchEnabled:TRUE];//enabling touch methods
        slides = [[NSMutableArray alloc] init];
        goingToTarget = false;
        Back = false;
        initialHolderX = initlevelnum;
        [self makeBackgrounds];
        [self makeArrows];
        [self makeMenu];
        [self makeSlides];
        [self schedule:@selector(Update)];
    }
    return self;
}
-(void) makeArrows
{
    arrow1 = [CCSprite spriteWithFile:@"Arrow.png"];
    arrow2 = [CCSprite spriteWithFile:@"Arrow.png"];
    arrow1.position = ccp(30, 160);
    [arrow2 runAction:[CCFlipX actionWithFlipX:YES]];
    arrow2.position = ccp(455, 160);
    [self addChild:arrow1 z:1];
    [self addChild:arrow2 z:1];
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event//screen is touched
{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    currentTouchX = touchLocation.x;
}
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    goingToTarget = false;
    previousTouchX = currentTouchX;
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    currentTouchX = touchLocation.x;
    holder.position = ccp(holder.position.x+(currentTouchX-previousTouchX), holder.position.y);
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(holder.position.x<-360)
    {
        [arrow1 setVisible:YES];
        [arrow2 setVisible:NO];
        targetX = -600;
    }
    else if(holder.position.x<40)
    {
        [arrow1 setVisible:YES];
        [arrow2 setVisible:YES];
        targetX = -180;
    }
    else 
    {
        [arrow1 setVisible:NO];
        [arrow2 setVisible:YES];
        targetX = 240;
    }
    goingToTarget = true;
}
-(void) makeMenu
{
    CCMenuItem* Back = [CCMenuItemImage itemFromNormalImage:@"Back_Arrow.png" selectedImage:@"Back_Arrow_Touch.png"target:self selector:@selector(goingBack)];
    Back.position = ccp(-210, 125);
    menu = [CCMenu menuWithItems: Back,nil];
    [self addChild:menu];
}
-(void) goingBack
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    Back = true;
}
-(bool) back
{
    return Back;
}
-(void) makeBackgrounds
{
    mg1 = [[SwappableCCSprite alloc]fileInitWithFrame:@">Grassland_MID_1.png" swapvalue:false];
    bg1 = [[SwappableCCSprite alloc]fileInitWithFrame:@">Grassland_BG_1.png" swapvalue:false];
    mg2 = [[SwappableCCSprite alloc]fileInitWithFrame:@"City_MID_1.png" swapvalue:false];
    bg2 = [[SwappableCCSprite alloc]fileInitWithFrame:@"City_BG_1.png" swapvalue:false];
    mg3 = [[SwappableCCSprite alloc]fileInitWithFrame:@"Mars_MID_1.png" swapvalue:false];
    bg3 = [[SwappableCCSprite alloc]fileInitWithFrame:@"Mars_BG_1.png" swapvalue:false];
    bg1.position=ccp(0, 160);
    bg2.position=ccp(240, 160);
    bg3.position=ccp(240, 160);
    mg1.position=ccp(0, [mg1 halfheight]);
    mg2.position=ccp(240, [mg2 halfheight]);
    mg3.position= ccp(240, [mg3 halfheight]);
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Level16"]<0)
    {
        [self addChild:bg1];
        [self addChild:mg1];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"Level31"]<0)
    {
        [self addChild:bg2];
        [self addChild:mg2];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"Level45"]<0)
    {
        [self addChild:bg3];
        [self addChild:mg3];
    }
    else
    {
        int rand = arc4random()%3;
        if(rand==0)
        {
            [self addChild:bg1];
            [self addChild:mg1];
        }
        else if (rand==1) 
        {
            [self addChild:bg2];
            [self addChild:mg2];
        }
        else
        {
            [self addChild:bg3];
            [self addChild:mg3];
        }
    }
}
-(void) makeSlides//makes slides for first time
{
    [slides addObject:[[ButtonSlide alloc]initwithbuttons:1 size:15]];
    [slides addObject:[[ButtonSlide alloc]initwithbuttons:16 size:15]];
    [slides addObject:[[ButtonSlide alloc]initwithbuttons:31 size:15]];
    holder = [[SlideHolder alloc]initWithArray:slides];
    [self addChild:holder];
    if(initialHolderX<16)
    {
        [arrow1 setVisible:NO];
        [arrow2 setVisible:YES];
        holder.position = ccp(240, holder.position.y);
    }
    else if(initialHolderX<31)
    {
        [arrow1 setVisible:YES];
        [arrow2 setVisible:YES];
        holder.position = ccp(-180, holder.position.y);
    }
    else
    {
        [arrow1 setVisible:YES];
        [arrow2 setVisible:NO];
        holder.position = ccp(-600, holder.position.y);
    }
}
-(void) Update
{
    if (goingToTarget)
    {
        int moveAmount = (targetX - holder.position.x)*.1;
        holder.position = ccp(holder.position.x+moveAmount, holder.position.y);
    }
    if(holder.position.x == targetX)
    {
        goingToTarget = false;
    }
    levelToPlay = [holder level];
}
-(void) SelectLevel: (CCMenuItem*) levelnum
{
    levelToPlay = levelnum.tag;
}
-(int) levelNumber
{
    return levelToPlay;
}
//ad whirl methods below this point
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
    newFrame.origin.y = (winSize.height-adSize.height+3);
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
    levelToPlay = 0;
    Back = false;
    [self removeAllChildrenWithCleanup:true];
    [mg1 release];
    [mg2 release];
    [mg3 release];
    [bg1 release];
    [bg2 release];
    [bg3 release];
    [slides removeAllObjects];
    [slides release];
    slides = nil;
    [holder release];
    [super dealloc];
}
@end
