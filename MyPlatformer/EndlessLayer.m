//
//  EndlessLayer.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EndlessLayer.h"
#import "Chunk.h"
#import "Player.h"
#import "Saw.h"
#import "Star.h"
#import "Background.h"
#import "FarBackground.h"
#import "SimpleAudioEngine.h"
NSMutableArray* backgrounds;
NSMutableArray* farbackgrounds;
Chunk* chunk1;
Chunk* chunk2;
Player* player;
@implementation EndlessLayer
@synthesize adWhirlView;
int currentChunkNum;
CCLabelTTF* tut1;
CCLabelTTF* tut2;
CCLabelTTF* tut3;
//score
int currentScore;
CCLabelTTF* score;
static const int intervalScoreAmount = 10;
static const int starScoreAmount = 1000;
CCMenu* menu; 
bool PlayerDead;
bool isFirstTime;
bool hasShowedSwappables;
//animation variables
CCSpriteBatchNode *starSpriteSheet;
CCSpriteBatchNode *bigSawSpriteSheet;
CCSpriteBatchNode *smallSawSpriteSheet;
CCSpriteBatchNode *gameObjectsSpriteBatch;
CCSpriteBatchNode *midBackgroundSpriteBatch;
CCSpriteBatchNode *farBackgroundSpriteBatch;
//pausing
CCMenu* pauseMenu;
CCLayer* pauseLayer;
bool goToMenu;
bool isPaused;
bool dying;

-(id) init//no load level neccesary as it is a one time deal do all your loading here
{
    if((self = [super initWithColor: ccc4(29,37,52,255)]))
    {
        [self setIsTouchEnabled:TRUE];//enabling touch methods
        PlayerDead = false;
        goToMenu = false;
        isPaused = false;
        dying = false;
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]==0)
        {
            isFirstTime = true;
            hasShowedSwappables = false;
        }
        else
        {
            hasShowedSwappables = true;
            isFirstTime = false;
        }
        currentScore = 0;
        currentChunkNum = 1; 
        [self cacheSpriteFrames];
        [self makeBackgrounds];
        chunk1 = [self newChunk];
        chunk2 = [self newChunk];
        [self addChunkChildren:chunk1];
        [self addChunkChildren:chunk2];
        //[self addChild:chunk1];
        //[self addChild:chunk2];
        player = [[Player alloc]initwithcoordinates:100 platform:[chunk1->platforms objectAtIndex:0] swapvalue:false];
        [gameObjectsSpriteBatch addChild:player z:25];
        [self makeLabel];
        [self makeHud];
        if(isFirstTime)
        {
            [self makeTuts];
        }
        [self schedule:@selector(Update)];
        [self schedule:@selector(addToScore) interval:.1];
    }
    return self;
}
-(void) makeTut3
{
    tut3 = [CCLabelTTF labelWithString:@"You can't flip on certain platforms" fontName:@"Arial" fontSize:20];
    tut3.position = ccp(250, 50);
    tut3.opacity = 0;
    id tut3sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut3 runAction:tut3sequnce];
    [self addChild:tut3];
}
-(void) makeTuts
{
    tut1 = [CCLabelTTF labelWithString:@"Touch the left side of the screen to jump" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(250, 50);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
    tut2 = [CCLabelTTF labelWithString:@"Touch the right side of the screen to flip" fontName:@"Arial" fontSize:20];
    tut2.position = ccp(250, 50);
    tut2.opacity = 0;
    id tut2sequnce = [CCSequence actions:[CCDelayTime actionWithDuration:5.5], [CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut2 runAction:tut2sequnce];
    [self addChild:tut1 z:5];
    [self addChild:tut2 z:5];
}
-(void) makeBackgrounds
{
    backgrounds = [[NSMutableArray alloc]init];
    farbackgrounds = [[NSMutableArray alloc]init];
    for(int i = 0; i<2; i++)
    {
        [backgrounds addObject:[[Background alloc] initwithcoordinates: 2 firstbackground:i]];
    }
    for(int i = 0; i<2; i++)
    {
        [farbackgrounds addObject:[[FarBackground alloc] initwithcoordinates:2 firstbackground:i]];
    }
    for(int i = 0; i<farbackgrounds.count;i++)
    {
        [farBackgroundSpriteBatch addChild:[farbackgrounds objectAtIndex:i]];
    }
    for(int i = 0; i<backgrounds.count;i++)
    {
        [midBackgroundSpriteBatch addChild:[backgrounds objectAtIndex:i]];
    }
}
-(void)addToScore
{
    currentScore+=intervalScoreAmount;
    NSString* myString = [NSString stringWithFormat:@"score:%d", currentScore];
    [score setString:myString];
}
-(int)score
{
    return currentScore;
}
-(void) makeLabel
{
    NSString* myString = [NSString stringWithFormat:@"score:%d", currentScore];
    score = [CCLabelTTF labelWithString:myString fontName:@"Arial" fontSize:25];
    score.position = ccp(80, 300);
    [self addChild:score z:999];
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event//screen is touched
{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    if(CGRectContainsPoint(CGRectMake(0, 0, 240, 280), touchLocation)&&!isPaused&&!dying)
    {
        [player playerJump];
    }
    else if(CGRectContainsPoint(CGRectMake(240, 0, 240, 280), touchLocation)&&!isPaused&&!dying)
    {
        [player playerSwap];
    }
    
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event//touch has left screen
{
    [player JumpButtonUp];//if the finger is taken off the screen (might change to when it leaves the bounding box)
}
-(bool)paused
{
    return isPaused;
}
-(void) Pause//pauses the game(makes a pause layer)
{
    if(isPaused == false)
    {
        [[SimpleAudioEngine sharedEngine]stopEffect:[player getRunEffect]];
        for(int i = 0; i<chunk1->saws.count;i++)
        {
            [[chunk1->saws objectAtIndex:i]stopSpinSound];
        }
        for(int i = 0; i<chunk2->saws.count;i++)
        {
            [[chunk2->saws objectAtIndex:i]stopSpinSound];
        }
        isPaused = true;
        [[CCDirector sharedDirector] pause];
        pauseLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 175) width:350 height:200];
        pauseLayer.position = ccp(75, 60);
        [self addChild:pauseLayer z:100];
        CCMenuItem* resumeButton = [CCMenuItemImage itemFromNormalImage:@"Resume.png" selectedImage:@"Resume_Touch.png" target:self selector:@selector(Resume)];
        resumeButton.position = ccp(0, 50);
        [resumeButton setScaleX:1.5];
        [resumeButton setScaleY:1.5];
        CCMenuItem* mainMenuButton = [CCMenuItemImage itemFromNormalImage:@"Main_Menu.png" selectedImage:@"Main_Menu_Touch.png" target:self selector:@selector(goToMenu)];
        mainMenuButton.position = ccp(0,-50);
        [mainMenuButton setScaleX:1.5];
        [mainMenuButton setScaleY:1.5];
        pauseMenu = [CCMenu menuWithItems:resumeButton, mainMenuButton, nil];
        [pauseMenu alignItemsVerticallyWithPadding:25];
        pauseMenu.position = ccp(175, 100);
        [pauseLayer addChild: pauseMenu z:500];
        [self onEnterPause];
    }
}
-(void) Resume
{
    [self onExitPause];
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    if(![player getDead]&&![player getJumping])
    {
        [player startRunEffect];
    }
    [pauseLayer removeAllChildrenWithCleanup:true];
    [self removeChild:pauseLayer cleanup:true];
    [[CCDirector sharedDirector]resume];
    isPaused = false;
}
-(void) goToMenu
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"]<currentScore)
    {
        [[NSUserDefaults standardUserDefaults]setInteger:currentScore forKey:@"highScore"];
    }
    [pauseLayer removeAllChildrenWithCleanup:true];
    [self removeChild:pauseLayer cleanup:true];
    [[CCDirector sharedDirector]resume];
    isPaused = false;
    goToMenu = true;
}
-(void) Update
{
    if(isPaused)
    {
        [[CCDirector sharedDirector] pause];
        return;
    }
    [player Update:[self arrayCombiner:chunk1->platforms array2:chunk2->platforms] unswappableplats:[self arrayCombiner:chunk1->unSwappablePlatforms array2:chunk2->unSwappablePlatforms] spike:[self arrayCombiner:chunk1->spikes array2:chunk2->spikes] saw:[self arrayCombiner:chunk1->saws array2:chunk2->saws]];//calls the update method via combining arrays of the two chunks two get all the objects that are on screen
    [chunk1 Update:player];//updating the chunks
    [chunk2 Update:player];
    for(int i = 0; i<[backgrounds count];i++)
    {
        [[backgrounds objectAtIndex:i] Update];
    }
    for(int i = 0; i<[farbackgrounds count];i++)
    {
        [[farbackgrounds objectAtIndex:i] Update];
    }
    [self DeleteObjects:player mychunk:chunk1];
    [self DeleteObjects:player mychunk:chunk2];
    if([chunk1 OffScreen])//moving chunk1 up front ( a new chunk)
    {
        [self removeChunkChildren:chunk1];
        [self removeChild:chunk1 cleanup:true];
        [chunk1 release];
        chunk1 = [self newChunk];
        [self addChunkChildren:chunk1];
        [self addChild:chunk1];
    }
    else if([chunk2 OffScreen])//moving chunk2 up front (a new chunk)
    {
        [self removeChunkChildren:chunk2];
        [self removeChild:chunk2 cleanup:true];
        [chunk2 release];
        chunk2 = [self newChunk];
        [self addChunkChildren:chunk2];
        [self addChild:chunk2];
    }
    [self playerDead];
}
-(void) playerDead
{
    if([player isDead:[self arrayCombiner:chunk1->spikes array2:chunk2->spikes] sawarray:[self arrayCombiner:chunk1->saws array2:chunk2->saws]])
    {
        dying = true;
        [self unschedule:@selector(Update)];
        [self unschedule:@selector(addToScore)];
        [self schedule:@selector(deadUpdate)];
        //PlayerDead = true;
    }
}
-(void) deadUpdate
{
    for(int i = 0; i<chunk1->saws.count;i++)
    {
        [[chunk1->saws objectAtIndex:i]deadUpdate];
    }
    for(int i = 0; i<chunk2->saws.count;i++)
    {
        [[chunk2->saws objectAtIndex:i]deadUpdate];
    }
    if ([player numberOfRunningActions]==0)
    {
        dying = false;
        for(int i = 0; i<chunk1->saws.count;i++)
        {
            [[chunk1->saws objectAtIndex:i]stopSpinSound];
        }
        for(int i = 0; i<chunk2->saws.count;i++)
        {
            [[chunk2->saws objectAtIndex:i]stopSpinSound];
        }
        PlayerDead = true;
        [self unschedule:@selector(deadUpdate)];
    }
}
-(NSMutableArray*) arrayCombiner: (NSMutableArray*) chunk1array array2: (NSMutableArray*) chunk2array
{
    NSMutableArray* returnArray;
    returnArray = [NSMutableArray arrayWithArray:chunk1array];
    [returnArray addObjectsFromArray:chunk2array];
    return returnArray;
}
-(void) makeHud
{
    CCMenuItem* pauseButton = [CCMenuItemImage itemFromNormalImage:@"Pause.png" selectedImage:@"Pause_Touch.png" target:self selector:@selector(pauseButton)];
    pauseButton.position = ccp(210, 133);
    menu = [CCMenu menuWithItems:pauseButton, nil];
    [self addChild:menu];
}
-(void) pauseButton
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    [self Pause];
}
-(Chunk*) newChunk
{
    Chunk* temp = [[Chunk alloc] initWithChunkNum:currentChunkNum];
    currentChunkNum++;
    return temp;
}
-(void) addChunkChildren: (Chunk*) chunk//called after chunk is inited
{   
    for (int i = 0; i<chunk->spikes.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[chunk->spikes objectAtIndex:i]];
    }
    for (int i = 0; i<chunk->stars.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[chunk->stars objectAtIndex:i]];
        [[chunk->stars objectAtIndex:i] turn]; //right now sections disappear :'( figure out
        //play animations
    }
    for (int i = 0; i<chunk->platforms.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[chunk->platforms objectAtIndex:i]];
    }
    for (int i = 0; i<chunk->unSwappablePlatforms.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[chunk->unSwappablePlatforms objectAtIndex:i]];
        if(isFirstTime&&!hasShowedSwappables)
        {
            [self makeTut3];
            hasShowedSwappables = true;
        }
    }
    for (int i = 0; i<chunk->saws.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[chunk->saws objectAtIndex:i]];
        [[chunk->saws objectAtIndex:i] spinAction];
    }
    for (int i = 0; i<chunk->nodes.count; i++)
    {
        [self addChild:[chunk->nodes objectAtIndex:i]];
    }
}
-(void) removeChunkChildren: (Chunk*) chunk//for full deletions of chunks
{
    for(int i = 0; i<chunk->saws.count;i++)
    {
        [[chunk->saws objectAtIndex:i]stopSpinSound];
    }
    for (int i = 0; i<chunk->spikes.count; i++)
    {
        [gameObjectsSpriteBatch removeChild:[chunk->spikes objectAtIndex:i] cleanup:true];
    }
    for (int i = 0; i<chunk->stars.count; i++)
    {
        [gameObjectsSpriteBatch removeChild:[chunk->stars objectAtIndex:i] cleanup:true];
    }
    for (int i = 0; i<chunk->platforms.count; i++)
    {
        [gameObjectsSpriteBatch removeChild:[chunk->platforms objectAtIndex:i] cleanup:true];
    }
    for (int i = 0; i<chunk->unSwappablePlatforms.count; i++)
    {
        [gameObjectsSpriteBatch removeChild:[chunk->unSwappablePlatforms objectAtIndex:i] cleanup:true];
    }
    for (int i = 0; i<chunk->saws.count; i++)
    {
        [gameObjectsSpriteBatch removeChild:[chunk->saws objectAtIndex:i] cleanup:true];
    }
    for (int i = 0; i<chunk->nodes.count; i++)
    {
        [self removeChild:[chunk->nodes objectAtIndex:i] cleanup:true];
    }
}
-(void) DeleteObjects: (Player*) player mychunk: (Chunk*) chunk//call this for both chunks
{
    for(int i = 0; i<[chunk->stars count];i++)
    {
        if([player IntersectsIgnoreSwap:[chunk->stars objectAtIndex:i]])
        {
            if(![[chunk->stars objectAtIndex:i]Deleted])
            {
                [[chunk->stars objectAtIndex:i ] stopAllActions];
                [[chunk->stars objectAtIndex:i]selfdelete];
                currentScore+=starScoreAmount;//changing the score
                [[SimpleAudioEngine sharedEngine] playEffect:@"star1.caf"];
                [[chunk->stars objectAtIndex:i]dissappear];
                NSString* myString = [NSString stringWithFormat:@"score:%d", currentScore];
                [score setString:myString];
                break;
            }
        }
        if([[chunk->stars objectAtIndex:i]Deleted]&&[[chunk->stars objectAtIndex:i]numberOfRunningActions]==0)
        {
            [gameObjectsSpriteBatch removeChild:[chunk->stars objectAtIndex:i] cleanup:true];
            [chunk->stars removeObjectAtIndex:i];
            break;
        }
        if([[chunk->stars objectAtIndex:i]isOffScreen])
        {
            [[chunk->stars objectAtIndex:i] stopAllActions];
            [gameObjectsSpriteBatch removeChild:[chunk->stars objectAtIndex:i] cleanup:true];
            [chunk->stars  removeObjectAtIndex:i];
            break;
        }
    } 
    for(int i = 0; i<[chunk->spikes count]; i++)//removes offscreen spikes
    {
        if([[chunk->spikes objectAtIndex:i]isOffScreen])
        {
            [gameObjectsSpriteBatch removeChild:[chunk->spikes objectAtIndex:i] cleanup:true];
            [chunk->spikes removeObjectAtIndex:i];
            break;//breaks so array traversal isn't f'ed
        }
    }
    for(int i = 0; i<[chunk->platforms count];i++)
    {
        if([[chunk->platforms objectAtIndex:i]isOffScreen])
        {
            [gameObjectsSpriteBatch removeChild:[chunk->platforms objectAtIndex:i] cleanup:true];
            [chunk->platforms removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[chunk->unSwappablePlatforms count];i++)
    {
        if([[chunk->unSwappablePlatforms objectAtIndex:i]isOffScreen])
        {
            [gameObjectsSpriteBatch removeChild:[chunk->unSwappablePlatforms objectAtIndex:i] cleanup:true];
            [chunk->unSwappablePlatforms removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[chunk->saws count];i++)
    {
        if([[chunk->saws objectAtIndex:i]isOffScreen])
        {
            [gameObjectsSpriteBatch removeChild:[chunk->saws objectAtIndex:i] cleanup:true];
            [[chunk->saws objectAtIndex:i]stopSpinSound];
            [chunk->saws removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[chunk->nodes count];i++)
    {
        if ([[chunk->nodes objectAtIndex:i]isOffScreen])
        {
            [self removeChild:[chunk->nodes objectAtIndex:i] cleanup:true];
            [chunk->nodes removeObjectAtIndex:i];
            break;
        }
    }
}
-(void) cacheSpriteFrames//the animation thing
{
    midBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"CityMIDAnim.png"];
    farBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"CityBGAnim.png"];
    [self addChild:farBackgroundSpriteBatch];
    [self addChild:midBackgroundSpriteBatch];
    gameObjectsSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameAnim.png"];
    [self addChild:gameObjectsSpriteBatch z:2];
}
-(bool) menu
{
    return  goToMenu;
}
-(bool) lost
{
    return PlayerDead;
}
-(void) dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    for(int i = 0; i<chunk1->saws.count;i++)
    {
        [[chunk1->saws objectAtIndex:i]stopSpinSound];
    }
    for(int i = 0; i<chunk2->saws.count;i++)
    {
        [[chunk2->saws objectAtIndex:i]stopSpinSound];
    }
    [[SimpleAudioEngine sharedEngine]stopEffect:[player getRunEffect]];
    goToMenu = false;
    isPaused = false;
    PlayerDead = false;
    [self removeAllChildrenWithCleanup:true];
    [farbackgrounds removeAllObjects];
    [farbackgrounds release];
    [backgrounds removeAllObjects];
    [backgrounds release];
    [chunk1 release];
    [chunk2 release];
    [player release];
    [super dealloc];
}
//adwhirl
-(void) adWhirlWillPresentFullScreenModal
{
    if(isPaused)
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [[CCDirector sharedDirector] pause];
    }
}
-(void) adWhirlDidDismissFullScreenModal
{
    if(isPaused)
    {
        return;
    }
    else
    {
        [[SimpleAudioEngine sharedEngine]resumeBackgroundMusic];
        [[CCDirector sharedDirector]resume];
    }
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
-(void)onEnterPause {
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
    //[super onEnter];
}

-(void)onExitPause {
    if (adWhirlView) {
        [adWhirlView removeFromSuperview];
        [adWhirlView replaceBannerViewWith:nil];
        [adWhirlView ignoreNewAdRequests];
        [adWhirlView setDelegate:nil];
        self.adWhirlView = nil;
    }
    //[super onExit];
}
-(void)onExit{
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
