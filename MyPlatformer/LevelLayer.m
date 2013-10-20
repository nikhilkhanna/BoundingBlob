//
//  LevelLayer.m
//  MyPlatformer
//
//  Created by Rocky Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "LevelLayer.h"
#import "Player.h"
#import "Spike.h"
#import "Star.h"
#import "LongSpike.h"
#import "Platform.h"
#import "UnswappablePlatform.h"
#import "PointFollower.h"
#import "FinishLine.h"
#import "Saw.h"
#import "Portal.h"
#import "Background.h"
#import "FarBackground.h"
#import "StarHolder.h"
#import "SimpleAudioEngine.h"
#import "Playtomic.h"
Player* player;
FinishLine* finish;
StarHolder* starHolder;
NSMutableArray* spikes;
NSMutableArray* stars;
NSMutableArray* platforms;
NSMutableArray* unSwappablePlatforms;
NSMutableArray* saws;
NSMutableArray* nodes;
NSMutableArray* portals;
NSMutableArray* backgrounds;
NSMutableArray* farbackgrounds;
bool hasSwapButton;
bool isPaused;
bool firstFrame;
CCMenu* menu; 
CCMenu* pauseMenu;
CCSprite* jumpButton;
CCSprite* swapButton;
CCSprite* controlShower;
CCLabelTTF* tut1;
CCLabelTTF* tut2;
CCLayer* pauseLayer;
bool hastut1;
bool hastut2;//the boolean for the tutorials
bool hasControlShower;
bool canDelete;
int starsCollected;
int levelNum;
bool isDone;
bool goToMenu;
bool dead;
//animations
CCSpriteBatchNode *gameObjectsSpriteBatch;
CCSpriteBatchNode *midBackgroundSpriteBatch;
CCSpriteBatchNode *farBackgroundSpriteBatch;
@implementation LevelLayer
@synthesize adWhirlView;
-(id) levelinit: (int) levelnum
{
    ccColor4B myColor;
    if(levelnum<16)
    {
        myColor = ccc4(135, 206, 235, 255);
    }
    else if(levelnum<31)
    {
        myColor = ccc4(29,37,52,255);
    }
    else
    {
        myColor = ccc4(115, 59, 15, 255);
    }
    if(self = [super initWithColor:myColor])
    {
        [self setIsTouchEnabled:TRUE];//enabling touch methods
        starsCollected = 0;
        levelNum = levelnum;
        isDone = false;
        hastut1= false;
        hastut2= false;
        hasControlShower = false;
        dead = false;
        canDelete = true;
        hasSwapButton = true;
        isPaused = false;
        goToMenu = false;
        [self Loadlevel:levelNum];
        [self schedule:@selector(Update)];
    }
    return self;
}
-(bool) paused
{
    return isPaused;
}
-(void) cacheSpriteFrames
{
    if(levelNum<16)
    {
        midBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GrassMIDAnim.png"];
        farBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GrassBGAnim.png"];
    }
    else if(levelNum<31)
    {
        midBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"CityMIDAnim.png"];
        farBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"CityBGAnim.png"];
    }
    else
    {
        midBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"MarsMIDAnim.png"];
        farBackgroundSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"MarsBGAnim.png"];
    }
    [self addChild:farBackgroundSpriteBatch];
    [self addChild:midBackgroundSpriteBatch];
    gameObjectsSpriteBatch = [CCSpriteBatchNode batchNodeWithFile:@"GameAnim.png"];
    [self addChild:gameObjectsSpriteBatch z:10];
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event//screen is touched
{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    if(CGRectContainsPoint(CGRectMake(0, 0, 240, 300), touchLocation)&&!isPaused&&!dead)
    {
        [self jump];
    }
    else if(hasSwapButton && CGRectContainsPoint(CGRectMake(240, 0, 240, 300), touchLocation)&&!isPaused&&!dead&&!firstFrame)
    {
        [self swap];
    }
    
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event//touch has left screen
{
    [player JumpButtonUp];//if the finger is taken off the screen (might change to when it leaves the bounding box)
}
-(void) Pause//pauses the game(makes a pause layer)
{
    if(isPaused == false)
    {
        for(int i = 0; i<saws.count;i++)
        {
            [[saws objectAtIndex:i]stopSpinSound];
        }
        [[SimpleAudioEngine sharedEngine]stopEffect:[player getRunEffect]];
        isPaused = true;
        [[CCDirector sharedDirector] pause];
        pauseLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 175) width:350 height:200];
        pauseLayer.position = ccp(75, 60);
        [self addChild:pauseLayer z:100];
        CCLabelTTF* levelLabel;
        NSString* levelString = [NSString stringWithFormat:@"Level %d",levelNum];
        levelLabel = [CCLabelTTF labelWithString:levelString fontName:@"Times New Roman" fontSize:35];
        levelLabel.position = ccp(175, 170);
        [pauseLayer addChild:levelLabel];
        levelLabel.color = ccc3(0, 0, 0);
        CCMenuItem* resumeButton = [CCMenuItemImage itemFromNormalImage:@"Resume.png" selectedImage:@"Resume_Touch.png" target:self selector:@selector(Resume)];
        resumeButton.position = ccp(-100, 0);
        [resumeButton setScaleX:1.5];
        [resumeButton setScaleY:1.5];
        CCMenuItem* mainMenuButton = [CCMenuItemImage itemFromNormalImage:@"Level_Select.png" selectedImage:@"Level_Select_Touch.png" target:self selector:@selector(goToMenu)];
        mainMenuButton.position = ccp(-100, 0);
        [mainMenuButton setScaleX:1.5];
        [mainMenuButton setScaleY:1.5];
        pauseMenu = [CCMenu menuWithItems:resumeButton, mainMenuButton, nil];
        [pauseMenu alignItemsVerticallyWithPadding:25];
        pauseMenu.position = ccp(175, 80);
        [pauseLayer addChild: pauseMenu z:500];
        [self onEnterPause];
    }
}
-(void) Resume//resumes game
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
    [pauseLayer removeAllChildrenWithCleanup:true];
    [self removeChild:pauseLayer cleanup:true];
    [[CCDirector sharedDirector]resume];
    isPaused = false;
    goToMenu = true;
}
-(bool) menu
{
    return goToMenu;
}
-(void) deadUpdate
{
    if ([player numberOfRunningActions]==0)
    {
        [self resetLevel];
    }
    for(int i = 0; i<saws.count;i++)
    {
        [[saws objectAtIndex:i]deadUpdate];
    }
}
-(void) Update//updates things called every frame
{
    if(isPaused)
    {
        [[CCDirector sharedDirector] pause];
        return;
    }
    [self UpdateObjects];
    [self DeleteObjects];
    if([self playerIsDead])
    {
        dead = true;
        [[Playtomic Log]customMetricName:[NSString stringWithFormat:@"DiedOnLevel@d", levelNum] andGroup:@"Deaths" andUnique:NO];
        [self unschedule:@selector(Update)];
        [self schedule:@selector(deadUpdate)];
    }
    firstFrame = false;
}
-(void) DeleteObjects
{
    for(int i = 0; i<[stars count];i++)
    {
        if([player IntersectsIgnoreSwap:[stars objectAtIndex:i]])
        {
            if(![[stars objectAtIndex:i]Deleted])
            {
                [[stars objectAtIndex:i ] stopAllActions];
                [[stars objectAtIndex:i]selfdelete];
                [[stars objectAtIndex:i]dissappear];
                starsCollected++;
                // if(starsCollected==1)
                [[SimpleAudioEngine sharedEngine] playEffect:@"star1.caf"];
                //else if(starsCollected==2)
                //[[SimpleAudioEngine sharedEngine] playEffect:@"star2.caf"];
                //else if(starsCollected==3)
                //  [[SimpleAudioEngine sharedEngine] playEffect:@"3star.caf"];
                [starHolder stopAllActions];
                [starHolder Animate:starsCollected];
                break;
            }
        }
        if([[stars objectAtIndex:i]Deleted]&&[[stars objectAtIndex:i]numberOfRunningActions]==0)
        {
            [gameObjectsSpriteBatch removeChild:[stars objectAtIndex:i] cleanup:true];
            [stars removeObjectAtIndex:i];
            break;
        }
        if([[stars objectAtIndex:i]isOffScreen]&&canDelete)
        {
            [gameObjectsSpriteBatch removeChild:[stars objectAtIndex:i] cleanup:true];
            [stars removeObjectAtIndex:i];
            break;
        }
    }
    if(canDelete)
    {
        for(int i = 0; i<[spikes count]; i++)//removes offscreen spikes
        {
            if([[spikes objectAtIndex:i]isOffScreen])
            {
                [gameObjectsSpriteBatch removeChild:[spikes objectAtIndex:i] cleanup:true];
                [spikes removeObjectAtIndex:i];
                break;//breaks so array traversal isn't f'ed
            }
        }
        for(int i = 0; i<[platforms count];i++)
        {
            if([[platforms objectAtIndex:i]isOffScreen])
            {
                [gameObjectsSpriteBatch removeChild:[platforms objectAtIndex:i] cleanup:true];
                [platforms removeObjectAtIndex:i];
                break;
            }
        }
        for(int i = 0; i<[unSwappablePlatforms count];i++)
        {
            if([[unSwappablePlatforms objectAtIndex:i]isOffScreen])
            {
                [gameObjectsSpriteBatch removeChild:[unSwappablePlatforms objectAtIndex:i] cleanup:true];
                [unSwappablePlatforms removeObjectAtIndex:i];
                break;
            }
        }
        for(int i = 0; i<[saws count];i++)
        {
            if([[saws objectAtIndex:i]isOffScreen])
            {
                [gameObjectsSpriteBatch removeChild:[saws objectAtIndex:i] cleanup:true];
                [saws removeObjectAtIndex:i];
                break;
            }
        }
        for(int i = 0; i<[nodes count];i++)
        {
            if ([[nodes objectAtIndex:i]isOffScreen])
            {
                [gameObjectsSpriteBatch removeChild:[nodes objectAtIndex:i] cleanup:true];
                [nodes removeObjectAtIndex:i];
                break;
            }
        }
    }
}
-(void) UpdateObjects
{
    [player Update: platforms unswappableplats:unSwappablePlatforms spike:spikes saw:saws];
    [finish Update];
    for(int i = 0; i<[spikes count];i++)
    {
        [[spikes objectAtIndex:i]Update];
    }
    for(int i = 0; i<[stars count];i++)
    {
        [[stars objectAtIndex:i]Update];
    }
    for(int i = 0; i<[platforms count];i++)
    {
        [[platforms objectAtIndex:i]Update];
    }
    for(int i = 0; i<[unSwappablePlatforms count];i++)
    {
        [[unSwappablePlatforms objectAtIndex:i]Update];
    }
    for(int i = 0; i<[saws count];i++)
    {
        [[saws objectAtIndex:i] Update];
    }
    for (int i = 0; i<[nodes count]; i++) 
    {
        [[nodes objectAtIndex:i] Update];
    }
    for(int i = 0; i<[portals count];i++)
    {
        [[portals objectAtIndex:i] Update];
    }
    for(int i = 0; i<[backgrounds count];i++)
    {
        [[backgrounds objectAtIndex:i] Update];
    }
    for(int i = 0; i<[farbackgrounds count];i++)
    {
        [[farbackgrounds objectAtIndex:i] Update];
    }
    [self updatePortal];
    [self updateCamera];
    [self playerWin];
}
-(void) updatePortal
{
    for(int i = 0; i<[portals count];i++)
    {
        [[portals objectAtIndex:i] teleportPlayer:player];
    }
}
-(void) updateCamera//updating the camera after player goes through a portal
{
    if(player.position.x!=100)
    {
        int correctionFactor;//the number added to each position every frame
        if(player.position.x>100)
            correctionFactor = (100-player.position.x)*.11;
        else 
            correctionFactor = (100-player.position.x)*.18;
        //moving all the objects
        [player updateCameraPosition:correctionFactor];
        [finish updateCameraPosition:correctionFactor];
        for(int i = 0; i<[spikes count];i++)
        {
            [[spikes objectAtIndex:i]updateCameraPosition:correctionFactor];
        }
        for(int i = 0; i<[stars count];i++)
        {
            [[stars objectAtIndex:i]updateCameraPosition:correctionFactor];
        }
        for(int i = 0; i<[platforms count];i++)
        {
            [[platforms objectAtIndex:i]updateCameraPosition:correctionFactor];
        }
        for(int i = 0; i<[unSwappablePlatforms count];i++)
        {
            [[unSwappablePlatforms objectAtIndex:i]updateCameraPosition:correctionFactor];
        }
        for(int i = 0; i<[saws count];i++)
        {
            [[saws objectAtIndex:i] updateCameraPosition:correctionFactor];
        }
        for (int i = 0; i<[nodes count]; i++) 
        {
            [[nodes objectAtIndex:i] updateCameraPosition:correctionFactor];
        }
        if(correctionFactor>.1)
        {
            for(int i = 0; i<[backgrounds count];i++)
            {
                [[backgrounds objectAtIndex:i] updateCameraPosition:correctionFactor];
            }
            for(int i = 0; i<[farbackgrounds count];i++)
            {
                [[farbackgrounds objectAtIndex:i] updateCameraPosition:correctionFactor];
            }
        }
        for(int i = 0; i<[portals count];i++)
        {
            [[portals objectAtIndex:i] updateCameraPosition:correctionFactor];
        }
    }
}
-(void) jump{
    [player playerJump];
}
-(void) swap{//make swap animation be the delay so you can't swap indefinatley
    [player playerSwap];
}
-(void) Loadlevel: (int) levelnum//loads level based on the level number
{
    platforms = [[NSMutableArray alloc] init];
    unSwappablePlatforms = [[NSMutableArray alloc] init];
    spikes = [[NSMutableArray alloc] init];
    stars = [[NSMutableArray alloc] init];
    saws = [[NSMutableArray alloc] init];
    nodes = [[NSMutableArray alloc] init];
    portals = [[NSMutableArray alloc] init];
    backgrounds = [[NSMutableArray alloc] init];
    farbackgrounds = [[NSMutableArray alloc] init];
    [self cacheSpriteFrames];
    starsCollected = 0;
    isPaused = false;
    dead = false;
    goToMenu = false;
    firstFrame = true;
    switch (levelnum) 
    {
        case 1:
            hasSwapButton = false;//first 5 lvls you can't swap
            hastut1 = true;
            hastut2 = true;
            hasControlShower = true;
            [self LoadLevel1];//calls the method for loading appropriate level, 1 in this case
            break;
        case 2:
            hasSwapButton = false;
            hastut1 = true;
            [self LoadLevel2];
            break;
        case 3:
            hastut1 = true;
            hasSwapButton = false;
            [self LoadLevel3];
            break;
        case 4:
            hastut1 = true;
            hasSwapButton = false;
            [self LoadLevel4];
            break;
        case 5:
            hasSwapButton = false;
            [self LoadLevel5];
            break;
        case 6:
            hastut1 = true;
            hastut2 = true;
            hasControlShower = true;
            [self LoadLevel6];
            break;
        case 7:
            hastut1 = true;
            [self LoadLevel7];
            break;
        case 8:
            [self LoadLevel8];
            break;
        case 9:
            hastut1 = true;
            [self LoadLevel9];
            break;
        case 10:
            hastut1 = true;
            [self LoadLevel10];
            break;
        case 11:
            [self LoadLevel11];
            break;
        case 12: 
            [self LoadLevel12];
            break;
        case 13: 
            [self LoadLevel13];
            break;
        case 14:
            [self LoadLevel14];
            break;
        case 15:
            [self LoadLevel15];
            break;
        case 16:
            hastut1 = true;
            [self LoadLevel16];
            break;
        case 17:
            [self LoadLevel17];
            break;
        case 18:
            [self LoadLevel18];
            break;
        case 19:
            [self LoadLevel19];
            break;
        case 20:
            [self LoadLevel20];
            break;
        case 21:
            [self LoadLevel21];
            break;
        case 22:
            hastut1 = true;
            [self LoadLevel22];
            break;
        case 23:
            [self LoadLevel23];
            break;
        case 24:
            [self LoadLevel24];
            break;
        case 25:
            [self LoadLevel25];
            break;
        case 26:
            [self LoadLevel26];
            break;
        case 27:
            [self LoadLevel27];
            break;
        case 28:
            [self LoadLevel28];
            break;
        case 29:
            [self LoadLevel29];
            break;
        case 30:
            [self LoadLevel30];
            break;
        case 31:
            hastut1 = true;
            [self LoadLevel31];
            break;
        case 32:
            [self LoadLevel32];
            break;
        case 33:
            hastut1 = true;
            [self LoadLevel33];
            break;
        case 34:
            hastut1 = true;
            [self LoadLevel34];
            break;
        case 35:
            hastut1 = true;
            [self LoadLevel35];
            break;
        case 36:
            [self LoadLevel36];
            break;
        case 37:
            [self LoadLevel37];
            break;
        case 38:
            [self LoadLevel38];
            break;
        case 39:
            [self LoadLevel39];
            break;
        case 40:
            [self LoadLevel40];
            break;
        case 41:
            [self LoadLevel41];
            break;
        case 42:
            [self LoadLevel42];
            break;
        case 43:
            [self LoadLevel43];
            break;
        case 44:
            [self LoadLevel44];
            break;
        case 45:
            [self LoadLevel45];
            break;
        default:
            [self LoadLevel1];
            break;
    }
    [self makeNodes];
    [self makeBackgrounds];
    [self addChildren];
    [self makeHud];
}
-(void) makeHud
{
    CCMenuItem* pauseButton = [CCMenuItemImage itemFromNormalImage:@"Pause.png" selectedImage:@"Pause_Touch.png" target:self selector:@selector(pauseButton)];
    pauseButton.position = ccp(210, 133);
    CCMenuItem* replayButton = [CCMenuItemImage itemFromNormalImage:@"Restart.png" selectedImage:@"Restart_Touch.png" target:self selector:@selector(restartLevel)];
    replayButton.position = ccp(155, 133);
    menu = [CCMenu menuWithItems:pauseButton,replayButton, nil];
    [self addChild:menu z:15];
    starHolder = [[StarHolder alloc]initWithFrame];
    [self addChild:starHolder z:15];
}
-(void) restartLevel
{
    if(!isPaused)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
        [self resetLevel];
    }
}
-(void) pauseButton
{
    if(!isPaused)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
        [self Pause];
    }
}
-(void) addChildren
{
    for(int i = 0; i<farbackgrounds.count;i++)
    {
        [farBackgroundSpriteBatch addChild:[farbackgrounds objectAtIndex:i]];
    }
    for(int i = 0; i<backgrounds.count;i++)
    {
        [midBackgroundSpriteBatch addChild:[backgrounds objectAtIndex:i]];
    }
    for(int i = 0; i<spikes.count; i++)//adding spikes
    {
        [gameObjectsSpriteBatch addChild:[spikes objectAtIndex:i]];
    }
    for(int i = 0; i<stars.count; i++)//and stars
    {
        [gameObjectsSpriteBatch addChild:[stars objectAtIndex:i] z:1];
        [[stars objectAtIndex:i]turn];
    }
    for(int i = 0; i<platforms.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[platforms objectAtIndex:i]];
    }
    for(int i = 0; i<unSwappablePlatforms.count; i++)//and stars
    {
        [gameObjectsSpriteBatch addChild:[unSwappablePlatforms objectAtIndex:i]];
    }
    for (int i = 0; i<nodes.count; i++)
    {
        [gameObjectsSpriteBatch addChild:[nodes objectAtIndex:i]];
    }
    for(int i = 0; i<saws.count;i++)
    {
        [gameObjectsSpriteBatch addChild:[saws objectAtIndex:i]];
        [[saws objectAtIndex:i] spinAction];
    }
    for(int i = 0; i<portals.count;i++)
    {
        [gameObjectsSpriteBatch addChild:[portals objectAtIndex:i]];
        [gameObjectsSpriteBatch addChild:[[portals objectAtIndex:i]portal2]];//adding the exit portals as children
        canDelete = false;//you can't delete as there is one or more portals
    }
    [gameObjectsSpriteBatch addChild:finish z:2];
    [gameObjectsSpriteBatch addChild:player z:1];
    //[playerSpriteSheet addChild:player];
    if(hastut1)
    {
        [self addChild:tut1 z:15];
    }
    if(hastut2)
    {
        [self addChild: tut2 z:15];
    }
    if(hasControlShower)
    {
        [self addChild: controlShower z:15];
    }
}
- (void) dealloc
{
    self.adWhirlView.delegate = nil;
    self.adWhirlView = nil;
    [self empty];
    [self unschedule:@selector(Update)];
	[super dealloc];
}
-(void) makeNodes//call this method at the end of levels with saws
{
    for(int i = 0; i<saws.count;i++)
    {
        CGPoint point1 = [[saws objectAtIndex:i]point1];
        CGPoint point2 = [[saws objectAtIndex:i]point2];
        [nodes addObject:[[PointFollower alloc]initWithPoint:point1]];
        [nodes addObject:[[PointFollower alloc]initWithPoint:point2]];
    }
}
-(void) makeBackgrounds
{
    int mySection;
    if(levelNum <16)
    {
        mySection = 1;
    }
    else if (levelNum <31)
    {
        mySection = 2;
    }
    else
    {
        mySection = 3;
    }
    for(int i = 0; i<2; i++)
    {
        [backgrounds addObject:[[Background alloc] initwithcoordinates: mySection firstbackground:i]];
    }
    for(int i = 0; i<2; i++)
    {
        [farbackgrounds addObject:[[FarBackground alloc] initwithcoordinates:mySection firstbackground:i]];
    }
}
-(void) empty
{
    firstFrame = true;
    for(int i = 0; i<saws.count;i++)
    {
        [[saws objectAtIndex:i]stopSpinSound];
    }
    [[SimpleAudioEngine sharedEngine]stopEffect:[player getRunEffect]];
    // don't forget to call "super dealloc"
    starsCollected = 0;
    [self removeAllChildrenWithCleanup:YES];
    goToMenu = false;
    [player release];
    player = nil;
    [starHolder release];
    starHolder = nil;
    controlShower = nil;
    tut1 = nil;
    tut2 = nil;
    if(hasControlShower)
    {
        [controlShower release];
    }
    swapButton = nil;
    [spikes removeAllObjects];
    [spikes release];
    spikes = nil;
    [platforms removeAllObjects];
    [platforms release];
    platforms = nil;
    [unSwappablePlatforms removeAllObjects];
    [unSwappablePlatforms release];
    unSwappablePlatforms = nil;
    [nodes removeAllObjects];
    [nodes release];
    nodes = nil;
    [saws removeAllObjects];
    [saws release];
    saws = nil;
    [stars removeAllObjects];
    [stars release];
    stars = nil;
    [portals removeAllObjects];
    [portals release];
    portals = nil;
    [backgrounds removeAllObjects];
    [backgrounds release];
    backgrounds = nil;
    [farbackgrounds removeAllObjects];
    [farbackgrounds release];
    farbackgrounds = nil;
    [finish release];
    finish = nil;
}
-(void) resetLevel
{
    for(int i = 0; i<saws.count;i++)
    {
        [[saws objectAtIndex:i]stopSpinSound];
    }
    [[SimpleAudioEngine sharedEngine]stopEffect:[player getRunEffect]];
    if(!isPaused)
    {
        [self empty];
        [self unscheduleAllSelectors];
        [self Loadlevel:levelNum];
        [self schedule:@selector(Update)];
    }
}
-(bool) playerIsDead
{
    if([player isDead:spikes sawarray:saws])
    {
        return true;
    }
    return false;
}
-(bool) playerWin
{
    if([player isWinner:finish])
    {
        [self removeChild:menu cleanup:true];
        return true;
    }
    return false;
}
-(int) starsCollected
{
    return starsCollected;
}


//----------------------------------------------------LOAD-LEVELS-BELOW-THIS-LINE-----------------------------------------------------//
-(void) LoadLevel1//basic
{
    [stars addObject:[[Star alloc]initwithcoordinates:600 ycoord:90 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1250 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1750 ycoord:90 swapvalue:false]];
    for(int i = 0; i<40;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:70]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:2500 ycoord:200 swapvalue:false];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:false];
    //tuts at bottom of level
    tut1 = [CCLabelTTF labelWithString:@"Tap here to jump hold to jump higher"dimensions:CGSizeMake(170, 240) alignment: UITextAlignmentCenter fontName:@"Arial" fontSize:20];
    tut1.position=ccp(120, 150);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    tut2 = [CCLabelTTF labelWithString:@"Reach the finish line to win!" fontName:@"Arial" fontSize:20];
    tut2.position=ccp(250, 200);
    tut2.opacity = 0;
    [tut2 setColor:ccc3(0, 0, 0)];
    id tut1sequence = [CCSequence actions:[CCFadeIn actionWithDuration:3],[CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequence];
    id tut2sequence = [CCSequence actions:[CCDelayTime actionWithDuration:7],[CCFadeIn actionWithDuration:3.5], nil];
    [tut2 runAction:tut2sequence];
    controlShower = [[CCSprite alloc]initWithFile:@"TouchAreaOutline.png"];
    controlShower.position = ccp(120, 140);
    controlShower.opacity = 0;
    id controlShowerSequence = [CCSequence actions:[CCDelayTime actionWithDuration:.3],[CCFadeIn actionWithDuration:2],[CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [controlShower runAction:controlShowerSequence];
}
-(void) LoadLevel2//death
{
    [stars addObject:[[Star alloc]initwithcoordinates:800 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:870 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:980 ycoord:70 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:50]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:990+(100*i) ycoord:50]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:1600 ycoord:200 swapvalue:false];    
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Watch out for pits and other hazards" fontName:@"Times New Roman" fontSize:20];
    tut1.position = ccp(220, 180);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel3//platforms
{
    [stars addObject:[[Star alloc]initwithcoordinates:600 ycoord:150 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:850 ycoord:210 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1200 ycoord: 100 swapvalue:false]];
    for(int i = 0; i <3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:50]];
    }
    for(int i = 0; i <3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:650+(200*i) ycoord:105]];
    }
    for(int i = 0; i <10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1250+(200*i) ycoord:50]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:1750 ycoord:200 swapvalue:false];   
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Try to get as many stars as you can" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(300, 180);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel4//spikes
{
    [stars addObject:[[Star alloc]initwithcoordinates:680 ycoord:75 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:780 ycoord:150 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:940 ycoord:150 swapvalue:false]];
    for(int i = 0; i <17;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:50]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:750 platform:[platforms objectAtIndex:3] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:1500 ycoord:200 swapvalue:false];   
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Don't touch the spikes!" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(220, 160);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel5//challenge
{
    [stars addObject:[[Star alloc]initwithcoordinates:500 ycoord:165 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1600 ycoord:215 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1800 ycoord:215 swapvalue:false]];
    for(int i = 0; i <2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:140+(200*i) ycoord:50]];
    }
    for(int i = 0; i <2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:630+(200*i) ycoord:50]];
    }
    for(int i = 0; i <4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1060+(200*i) ycoord:100]];
    }
    for(int i = 0; i <10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1950+(200*i) ycoord:60]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[platforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1600 platform:[platforms objectAtIndex:7] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:2450 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel6//first swapping level (swag tutorial text)
{
    [stars addObject:[[Star alloc]initwithcoordinates:800 ycoord:155 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:900 ycoord:100 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1300 ycoord:155 swapvalue:false]];
    for (int i = 0;i<16; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:125]];
    }
    for(int i = 0; i<6;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:900+(50*i) platform:[platforms objectAtIndex:5] swapvalue:false]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:1700 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Sometimes the only way forward is to flip!" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(250, 250);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    tut2 = [CCLabelTTF labelWithString:@"Tap here to flip" fontName:@"Arial" fontSize:20];
    tut2.position = ccp(360, 200);
    tut2.opacity = 0;
    [tut2 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:1], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    id tut2sequnce = [CCSequence actions: [CCDelayTime actionWithDuration:2.5],[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
    [tut2 runAction:tut2sequnce];
    controlShower = [[CCSprite alloc]initWithFile:@"TouchAreaOutline.png"];
    controlShower.position = ccp(360, 140);
    controlShower.opacity = 0;
    id controlShowerSequence = [CCSequence actions:[CCDelayTime actionWithDuration:2.5],[CCFadeIn actionWithDuration:2],[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [controlShower runAction:controlShowerSequence];
}
-(void) LoadLevel7//jumping while swapping
{
    [stars addObject:[[Star alloc]initwithcoordinates:500 ycoord:165 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:920 ycoord:45 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1400 ycoord:150 swapvalue:false]];
    for (int i = 0;i<4; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:175+(200*i) ycoord:125]];
    }
    for (int i = 0;i<12; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1050+(200*i) ycoord:125]];
    }
    for(int i = 0; i<3;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:750+(50*i) platform:[platforms objectAtIndex:3] swapvalue:false]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:1950 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"While flipped you can still jump" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(240, 200);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:2], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel8//advanced 1-d swapping(swapped spikes) 
{
    [stars addObject:[[Star alloc]initwithcoordinates:450 ycoord:40 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:700 ycoord:225 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1000 ycoord:225 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:175+(200*i) ycoord:125]];
    }
    for (int i = 0;i<12; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:870+(200*i) ycoord:125]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:450 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:450 platform:[platforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:650 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1000 platform:[platforms objectAtIndex:7] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:1400 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel9
{
    [stars addObject:[[Star alloc]initwithcoordinates:400 ycoord:60 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:850 ycoord:260 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1600 ycoord:260 swapvalue:false]];
    for (int i = 0;i<4; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for (int i = 0;i<13; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1000+(200*i) ycoord:160]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:2000 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(true)];
    [spikes addObject:[[Spike alloc] initwithcoordinates:400 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:400 platform:[platforms objectAtIndex:2] swapvalue:true]];
    for(int i = 0; i<5;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:1000+(50*i) platform:[platforms objectAtIndex:5] swapvalue:false]];  
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1600 platform:[platforms objectAtIndex:5] swapvalue:false]];
    tut1 = [CCLabelTTF labelWithString:@"You can only flip while on the ground" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(280, 250);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:1.5], [CCDelayTime actionWithDuration:1.4], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel10//2d swapping
{
    [stars addObject:[[Star alloc]initwithcoordinates:650 ycoord:40 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1320 ycoord:290 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1700 ycoord:40 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:175+(200*i) ycoord:70]];
    }
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:750+(200*i) ycoord:220]];
    }
    for (int i = 0;i<9; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1500+(200*i) ycoord:70]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:2100 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Flipping reverses gravity" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(250, 160);
    tut1.opacity = 0;
    [tut1 setColor:ccc3(0, 0, 0)];
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:1.5], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel11
{
    [stars addObject:[[Star alloc]initwithcoordinates:720 ycoord:230 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:920 ycoord:40 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1600 ycoord:260 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:175+(200*i) ycoord:160]];
    }
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:800+(200*i) ycoord:60]];
    }
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:800+(200*i) ycoord:260]];
    }
    for (int i = 0;i<9; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1300+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:650 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1000 platform:[platforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1050 platform:[platforms objectAtIndex:4] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:950 platform:[platforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:950 platform:[platforms objectAtIndex:8] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:1850 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(true)];
}
-(void) LoadLevel12
{
    [stars addObject:[[Star alloc]initwithcoordinates:750 ycoord:25 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1200 ycoord:175 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1710 ycoord:240 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:175+(200*i) ycoord:100]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:890+(200*i) ycoord:100]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1350+(200*i) ycoord:170]];
    }
    for (int i = 0;i<8; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1800+(200*i) ycoord:110]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:480 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:530 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:950 platform:[platforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1625 platform:[platforms objectAtIndex:6] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:1980 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(true)];
}
-(void) LoadLevel13
{
    [stars addObject:[[Star alloc]initwithcoordinates:600 ycoord:25 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:950 ycoord:220 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1200 ycoord:25 swapvalue:false]];
    for (int i = 0;i<16; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:120]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:350 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:400 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:600 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:950 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:650 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[platforms objectAtIndex:1] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:1600 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel14
{
    [stars addObject:[[Star alloc]initwithcoordinates:1300 ycoord:170 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2250 ycoord:215 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3300 ycoord:100 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:-80+(200*i) ycoord:210]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:635+(200*i) ycoord:210]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1150+(200*i) ycoord:210]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1400+(200*i) ycoord:135]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1900+(200*i) ycoord:135]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2400+(200*i) ycoord:135]];
    }
    for (int i = 0;i<4; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2700+(200*i) ycoord:210]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3100+(200*i) ycoord:135]];
    }
    for (int i = 0;i<10; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3300+(200*i) ycoord:60]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:3900 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel15
{
    [stars addObject:[[Star alloc]initwithcoordinates:690 ycoord:130 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:800 ycoord:175 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1930 ycoord:175 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:150+(200*i) ycoord:170]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:780+(200*i) ycoord:200]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1200+(200*i) ycoord:80]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1700+(200*i) ycoord:80]];
    }
    [platforms addObject:[[Platform alloc] initwithcoordinates:1930 ycoord:150]];
    for (int i = 0;i<9; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1930+(200*i) ycoord:230]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:490 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:625 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:480 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:625 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:900 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1055 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:8] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:2300 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel16//the unswappables
{
    [stars addObject:[[Star alloc]initwithcoordinates:400 ycoord:145 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:730 ycoord:95 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1250 ycoord:145 swapvalue:false]];
    for (int i = 0;i<4; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:0+(200*i) ycoord:120]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:700+(200*i) ycoord:120]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1300+(200*i) ycoord:120]];
    }
    for(int i = 0; i<9;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1700+(200*i) ycoord:120]];
    }
    for(int i = 0;i<5;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:700+(50*i) platform:[platforms objectAtIndex:4] swapvalue:false]];
    }
    for(int i = 0;i<5;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:1700+(50*i) platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:2300 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"You cannot flip on steel platforms" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(275, 200);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel17//i'm ensure if 16-18 are in a good order double check it
{
    [stars addObject:[[Star alloc]initwithcoordinates:400 ycoord:20 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1225 ycoord:255 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2410 ycoord:65 swapvalue:false]];
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:90]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:550+(200*i) ycoord:160]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1150+(200*i) ycoord:230]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1700+(200*i) ycoord:90]];
    }
    [platforms addObject:[[Platform alloc] initwithcoordinates:2100 ycoord:90]];
    for(int i = 0; i<8;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2410+(200*i) ycoord:90]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:600 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:750 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:750 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:900 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1325 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2025 platform:[unSwappablePlatforms objectAtIndex:6] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:2700 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel18
{
    [stars addObject:[[Star alloc]initwithcoordinates:700 ycoord:135 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1100 ycoord:300 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2050 ycoord:60 swapvalue:false]];
    for (int i = 0;i<3; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:700 ycoord:160]];
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:900+(20*i) ycoord:220]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1245+(200*i) ycoord:220]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1675+(200*i) ycoord:160]];
    }
    for (int i = 0;i<11; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2150+(200*i) ycoord:220]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:350 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:450 platform:[platforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:910 platform:[platforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1275 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1350 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1425 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1750 platform:[platforms objectAtIndex:6] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1850 platform:[platforms objectAtIndex:6] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:2600 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel19//should probably level 18 more of a challenge level
{
    [stars addObject:[[Star alloc]initwithcoordinates:1075 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1500 ycoord:20 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2100 ycoord:170 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:90]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1025+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1500+(200*i) ycoord:90]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1400+(200*i) ycoord:230]];
    }
    for(int i = 0; i<6;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1900+(200*i) ycoord:195]];
    }
    for(int i = 0; i<9;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2200+(200*i) ycoord:90]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:500 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:680 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1500 platform:[unSwappablePlatforms objectAtIndex:7] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1650 platform:[unSwappablePlatforms objectAtIndex:7] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1800 platform:[unSwappablePlatforms objectAtIndex:7] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1600 platform:[unSwappablePlatforms objectAtIndex:10] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:2320 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(true)];
}
-(void) LoadLevel20
{
    [stars addObject:[[Star alloc]initwithcoordinates:860 ycoord:30 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2275 ycoord:290 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3330 ycoord:80 swapvalue:false]];
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:90]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:500+(200*i) ycoord:90]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:950+(200*i) ycoord:160]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1220+(200*i) ycoord:220]];
    }
    for (int i = 0;i<1; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1790+(200*i) ycoord:90]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1950+(200*i) ycoord:220]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2450+(200*i) ycoord:220]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2710+(200*i) ycoord:220]];
    }
    for (int i = 0;i<9; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3160+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:375 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:660 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:560 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1025 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1350 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2525 platform:[unSwappablePlatforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2710 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2710 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2910 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3300 platform:[platforms objectAtIndex:7] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:3600 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel21
{
    [stars addObject:[[Star alloc]initwithcoordinates:590 ycoord:30 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1400 ycoord:280 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3200 ycoord:160 swapvalue:false]];
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:200+(200*i) ycoord:84]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:650+(200*i) ycoord:160]];
    }
    for (int i = 0;i<1; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1200+(200*i) ycoord:240]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1375+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1900+(200*i) ycoord:160]];
    }
    for (int i = 0;i<2; i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2360+(200*i) ycoord:160]];
    }
    for(int i = 0; i<11;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2845+(200*i) ycoord:50]];
    }
    for(int i = 0; i<11;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2845+(200*i) ycoord:270]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:700 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:900 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:750 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:925 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1050 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1500 platform:[unSwappablePlatforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1550 platform:[unSwappablePlatforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1900 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2175 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1950 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2900 platform:[unSwappablePlatforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3050 platform:[unSwappablePlatforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3325 platform:[unSwappablePlatforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3475 platform:[unSwappablePlatforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3000 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3375 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    finish = [[FinishLine alloc]initwithcoordinates:3800 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel22//saws
{
    [stars addObject:[[Star alloc]initwithcoordinates:800 ycoord:160 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1300 ycoord:160 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1700 ycoord:40 swapvalue:false]];
    [saws addObject:[[Saw alloc] initwithpoints:550 y:70 nextx:850 nexty:70 speed: 2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1300 y:10 nextx:1300 nexty:305 speed: 3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1700 y:70 nextx:2000 nexty:70 speed: 3 big:true]];
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:125+(200*i) ycoord:70]];
    }
    for(int i = 0; i<16;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1230+(200*i) ycoord:70]];
    }
    finish = [[FinishLine alloc]initwithcoordinates:2300 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    tut1 = [CCLabelTTF labelWithString:@"Watch out for the moving sawblades" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(260, 200);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel23//mid saw(small saws)
{
    [stars addObject:[[Star alloc]initwithcoordinates:400 ycoord:130 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:875 ycoord:240 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1800 ycoord:300 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:-100+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:530+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1250+(200*i) ycoord:160]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1700+(200*i) ycoord:220]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:600 platform:[platforms objectAtIndex:4] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:900 platform:[platforms objectAtIndex:4] swapvalue:true]];
    [saws addObject:[[Saw alloc] initwithpoints:450 y:300 nextx:450 nexty:80 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1000 y:190 nextx:700 nexty:190 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1300 y:100 nextx:1300 nexty:280 speed:2 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2000 y:220 nextx:1600 nexty:220 speed:3 big:true]];
    finish = [[FinishLine alloc]initwithcoordinates:2300 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel24 //hard saw(fast moving)
{
    [stars addObject:[[Star alloc]initwithcoordinates:935 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1800 ycoord:240 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2650 ycoord:290 swapvalue:false]];
    for(int i = 0; i<12;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2500+(200*i) ycoord:220]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3200+(200*i) ycoord:220]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3610+(200*i) ycoord:90]];
    }
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3300 platform:[platforms objectAtIndex:16] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3300 platform:[platforms objectAtIndex:16] swapvalue:false]];
    [saws addObject:[[Saw alloc] initwithpoints:450 y:200 nextx:450 nexty:100 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:720 y:180 nextx:1300 nexty:180 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1300 y:140 nextx:720 nexty:140 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2000 y:180 nextx:1400 nexty:180 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2500 y:300 nextx:2900 nexty:140 speed:2.95 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3575 y:300 nextx:3560 nexty:100 speed:3 big:true]];
    finish = [[FinishLine alloc]initwithcoordinates:3900 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel25
{
    [stars addObject:[[Star alloc]initwithcoordinates:450 ycoord:75 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2030 ycoord:180 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2575 ycoord:260 swapvalue:false]];
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:610+(200*i) ycoord:160]];
    }
    for(int i = 0; i<13;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2725+(200*i) ycoord:160]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:450 y:220 nextx:450 nexty:100 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:700 y:160 nextx:1600 nexty:160 speed:6.3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:190 nextx:2400 nexty:190 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:250 nextx:2400 nexty:250 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:130 nextx:2400 nexty:130 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2800 y:160 nextx:3600 nexty:160 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3600 y:160 nextx:2800 nexty:160 speed:5 big:false]];
    finish = [[FinishLine alloc]initwithcoordinates:3900 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel26
{
    [stars addObject:[[Star alloc]initwithcoordinates:900 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2175 ycoord:130 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2600 ycoord:70 swapvalue:false]];
    for(int i = 0; i<31;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:700 y:160 nextx:-5000 nexty:160 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1150 y:190 nextx:-5000 nexty:190 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1450 y:190 nextx:-5000 nexty:190 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1600 y:130 nextx:-5000 nexty:130 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1600 y:70 nextx:-5000 nexty:70 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3200 y:190 nextx:-5000 nexty:190 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3200 y:250 nextx:-5000 nexty:250 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3700 y:160 nextx:-5000 nexty:160 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4000 y:190 nextx:-5000 nexty:190 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5200 y:190 nextx:-5000 nexty:190 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5200 y:250 nextx:-5000 nexty:250 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5500 y:130 nextx:-5000 nexty:130 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5500 y:70 nextx:-5000 nexty:70 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:7600 y:130 nextx:-5000 nexty:130 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:7700 y:160 nextx:-5000 nexty:160 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4300 y:190 nextx:-5000 nexty:190 speed:1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4300 y:250 nextx:-5000 nexty:250 speed:1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4300 y:130 nextx:-5000 nexty:130 speed:1 big:true]];
    finish = [[FinishLine alloc]initwithcoordinates:3900 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel27//saws+unswaps
{
    [stars addObject:[[Star alloc]initwithcoordinates:850 ycoord:300 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2625 ycoord:205 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3950 ycoord:220 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:220]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1050+(200*i) ycoord:160]];
    }
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1450+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2200+(200*i) ycoord:90]];
    }
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2700+(200*i) ycoord:80]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2500+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3400+(200*i) ycoord:155]];
    }
    for(int i = 0; i<12;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates:4100+(200*i) ycoord:155]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:350 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:550 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:720 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4300 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1400 y:160 nextx:2050 nexty:160 speed:8 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2700 y:220 nextx:3400 nexty:220 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:220 nextx:2700 nexty:220 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:80 nextx:3400 nexty:80 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:80 nextx:2600 nexty:80 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:4000 y:155 nextx:4800 nexty:155 speed:5 big:true]];
    finish = [[FinishLine alloc]initwithcoordinates:5200 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel28
{
    [stars addObject:[[Star alloc]initwithcoordinates:450 ycoord:130 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2650 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:4700 ycoord:160 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<9;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:500+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2300+(200*i) ycoord:160]];
    }
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2800+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3500+(200*i) ycoord:160]];
    }
    for(int i = 0; i<13;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3800+(200*i) ycoord:50]];
    }
    for(int i = 0; i<13;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3800+(200*i) ycoord:270]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:2200 y:160 nextx:500 nexty:160 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2200 y:90 nextx:500 nexty:90 speed:4 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1600 y:175 nextx:1600 nexty:300 speed:2 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:920 y:175 nextx:920 nexty:300 speed:2 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3500 y:140 nextx:2900 nexty:140 speed:4 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2900 y:140 nextx:3500 nexty:140 speed:3 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3500 y:190 nextx:2900 nexty:190 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2900 y:190 nextx:3500 nexty:190 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:50 nextx:4900 nexty:50 speed:5 big:true]];
    //  [saws addObject:[[Saw alloc] initwithpoints:4900 y:270 nextx:3900 nexty:270 speed:4.5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:270 nextx:4900 nexty:270 speed:4 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:270 nextx:4900 nexty:270 speed:5 big:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4200 platform:[unSwappablePlatforms objectAtIndex:16] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4400 platform:[unSwappablePlatforms objectAtIndex:16] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4900 platform:[unSwappablePlatforms objectAtIndex:16] swapvalue:false]];
    finish = [[FinishLine alloc]initwithcoordinates:5250 ycoord:200 swapvalue:false];  
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
}
-(void) LoadLevel29//make sure its not too hard :"(
{
    [stars addObject:[[Star alloc]initwithcoordinates:700 ycoord:80 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2000 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3000 ycoord:160 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:700+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1300+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1900+(200*i) ycoord:220]];
    }
    for(int i = 0; i<13;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2550+(200*i) ycoord:90]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:650 y:220 nextx:650 nexty:100 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:700 y:220 nextx:1200 nexty:220 speed:2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:250 nextx:1500 nexty:250 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:185 nextx:1200 nexty:185 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2000 y:140 nextx:2000 nexty:300 speed:2.9 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:120 nextx:3650 nexty:120 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3650 y:120 nextx:2600 nexty:120 speed:4 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:400 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1250 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1450 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1520 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3300 platform:[unSwappablePlatforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3000 platform:[unSwappablePlatforms objectAtIndex:10] swapvalue:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(true)];
    finish = [[FinishLine alloc]initwithcoordinates:3900 ycoord:200 swapvalue:false];  
}
-(void) LoadLevel30
{
    [stars addObject:[[Star alloc]initwithcoordinates:1650 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3400 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:5200 ycoord:180 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:700+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1300+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1800+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2500+(200*i) ycoord:160]];
    }
    for(int i = 0; i<12;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:3200+(200*i) ycoord:160]];
    }
    for(int i = 0; i<8;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:5600+(200*i) ycoord:160]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:600 y:195 nextx:1200 nexty:195 speed:3 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1200 y:195 nextx:600 nexty:195 speed:3 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:600 y:195 nextx:1200 nexty:195 speed:4 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1200 y:125 nextx:600 nexty:125 speed:2.8 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:600 y:125 nextx:1200 nexty:125 speed:4.2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1700 y:160 nextx:2300 nexty:160 speed:7 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2400 y:160 nextx:3000 nexty:160 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3000 y:160 nextx:2400 nexty:160 speed:3 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3100 y:160 nextx:5500 nexty:160 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5500 y:160 nextx:3100 nexty:160 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3100 y:160 nextx:5500 nexty:160 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3600 y:180 nextx:3100 nexty:180 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:4100 y:140 nextx:3600 nexty:140 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:180 nextx:4100 nexty:180 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5100 y:140 nextx:4600 nexty:140 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5600 y:180 nextx:5100 nexty:180 speed:5.9 big:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:650 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1000 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2050 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1800 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:5900 ycoord:200 swapvalue:false];
}
-(void) LoadLevel31//portal intro
{
    [stars addObject:[[Star alloc]initwithcoordinates:750 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1400 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1650 ycoord:70 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1200+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:800 p1:[platforms objectAtIndex:0] x2:1100 p2:[platforms objectAtIndex:5]first:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:2000 ycoord:200 swapvalue:false];
    tut1 = [CCLabelTTF labelWithString:@"The green teleporter sends you to the red one" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(270, 250);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:1], [CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel32//going backwards using portals
{
    [stars addObject:[[Star alloc]initwithcoordinates:960 ycoord:100 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1250 ycoord:160 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1700 ycoord:300 swapvalue:false]];
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:70]];
    }
    for(int i = 0; i<6;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:220]];
    }
    for(int i = 0; i<9;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1400+(200*i) ycoord:220]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:1000 p1:[unSwappablePlatforms objectAtIndex:0] x2:200 p2:[platforms objectAtIndex:0]first:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:570 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:570 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:850 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:725 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1500 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1500 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:0] swapvalue:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:2000 ycoord:200 swapvalue:false];
}
-(void) LoadLevel33//1 pair of portal challenge level + jumping over portals (stars to guide player)
{
    [stars addObject:[[Star alloc]initwithcoordinates:850 ycoord:190 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1400 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2200 ycoord:250 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:900+(200*i) ycoord:160]];
    }
    for(int i = 0; i<11;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2010+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:1400 p1:[unSwappablePlatforms objectAtIndex:0] x2:200 p2:[platforms objectAtIndex:0]first:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:500 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:550 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1000 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:950 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1150 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1200 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2200 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    for(int i = 0; i<7;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:1450+(50*i) platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    }
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:2500 ycoord:200 swapvalue:false]; 
    tut1 = [CCLabelTTF labelWithString:@"You cannot enter the red teleporter" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(260, 260);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:1], [CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel34
{
    [stars addObject:[[Star alloc]initwithcoordinates:725 ycoord:30 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1525 ycoord:300 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2850 ycoord:30 swapvalue:false]];
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:100+(200*i) ycoord:120]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:1350+(200*i) ycoord:230]];
    }
    for(int i = 0; i<13;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates:2200+(200*i) ycoord:120]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:1000 p1:[platforms objectAtIndex:0] x2:1250 p2:[platforms objectAtIndex:6]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:1850 p1:[platforms objectAtIndex:6] x2:2100 p2:[platforms objectAtIndex:10]first:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:350 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:475 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:600 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:725 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:850 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1525 platform:[platforms objectAtIndex:6] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1625 platform:[platforms objectAtIndex:6] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:6] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2390 platform:[platforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2390 platform:[platforms objectAtIndex:10] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2500 platform:[platforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2550 platform:[platforms objectAtIndex:10] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2650 platform:[platforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2850 platform:[platforms objectAtIndex:10] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:3100 ycoord:200 swapvalue:false]; 
    tut1 = [CCLabelTTF labelWithString:@"There can be more than one pair of teleporters" fontName:@"Arial" fontSize:20];
    tut1.position = ccp(260, 260);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel35
{
    [stars addObject:[[Star alloc]initwithcoordinates:50 ycoord:120 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1550 ycoord:210 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:900 ycoord:20 swapvalue:false]];
    for(int i = 0; i<20;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:-300+(200*i) ycoord:90]];
    }
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:900+(200*i) ycoord:240]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:900 p1:[unSwappablePlatforms objectAtIndex:0] x2:800 p2:[platforms objectAtIndex:1]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:1600 p1:[platforms objectAtIndex:2] x2:-400 p2:[unSwappablePlatforms objectAtIndex:0]first:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:650 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:950 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1050 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1200 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1300 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1375 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1475 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:0 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:175 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:300 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:500 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:675 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1150 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1325 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1500 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1630 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1750 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1925 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2075 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    for(int i = 0; i<10;i++)
    {
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:1000+(100*i) platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    }
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:2400 ycoord:200 swapvalue:false]; 
    tut1 = [CCLabelTTF labelWithString:@"You remain flipped if you enter a teleporter while flipped" fontName:@"Arial" fontSize:18];
    tut1.position = ccp(250, 220);
    tut1.opacity = 0;
    id tut1sequnce = [CCSequence actions:[CCFadeIn actionWithDuration:2], [CCDelayTime actionWithDuration:3], [CCFadeOut actionWithDuration:1], nil];
    [tut1 runAction:tut1sequnce];
}
-(void) LoadLevel36
{
    [stars addObject:[[Star alloc]initwithcoordinates:1700 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1700 ycoord:190 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1250 ycoord:120 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:90]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1000+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1400+(200*i) ycoord:220]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2000+(200*i) ycoord:150]];
    }
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2720+(200*i) ycoord:150]];
    }
    for(int i = 0; i<15;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3625+(200*i) ycoord:150]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:800 p1:[platforms objectAtIndex:0] x2:900 p2:[platforms objectAtIndex:5]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:3800 p1:[platforms objectAtIndex:16] x2:1500 p2:[unSwappablePlatforms objectAtIndex:0]first:false]];
    [saws addObject:[[Saw alloc] initwithpoints:600 y:40 nextx:600 nexty:180 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1150 y:250 nextx:1300 nexty:160 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1900 y:150 nextx:2500 nexty:150 speed:7 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3420 y:150 nextx:2620 nexty:150 speed:5.69 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2620 y:150 nextx:3420 nexty:150 speed:6.59 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:150 nextx:4700 nexty:150 speed:4.1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:150 nextx:4700 nexty:150 speed:5.2 big:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:350 platform:[platforms objectAtIndex:0] swapvalue:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:5000 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel37
{
    [stars addObject:[[Star alloc]initwithcoordinates:400 ycoord:100 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1600 ycoord:110 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3000 ycoord:60 swapvalue:false]];
    for(int i = 0; i<6;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:130]];
    }
    for(int i = 0; i<8;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1350+(200*i) ycoord:200]];
    }
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3000+(200*i) ycoord:90]];
    }
    for(int i = 0; i<13;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3600+(200*i) ycoord:90]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:1900 p1:[platforms objectAtIndex:1] x2:100 p2:[unSwappablePlatforms objectAtIndex:0]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:4400 p1:[platforms objectAtIndex:11] x2:2900 p2:[unSwappablePlatforms objectAtIndex:7]first:false]];
    [saws addObject:[[Saw alloc] initwithpoints:500 y:160 nextx:1200 nexty:160 speed:7 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1200 y:100 nextx:500 nexty:100 speed:7 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1600 y:245 nextx:1600 nexty:155 speed:4.3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2100 y:200 nextx:2700 nexty:200 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2700 y:200 nextx:2100 nexty:200 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3100 y:90 nextx:3500 nexty:90 speed:5.9 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3900 y:145 nextx:3900 nexty:35 speed:6 big:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:4750 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel38//change up the order of this and previous 2 levels in order of difficulty
{
    [stars addObject:[[Star alloc]initwithcoordinates:1450 ycoord:20 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2300 ycoord:200 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:4100 ycoord:250 swapvalue:false]];
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:100]];
    }
    for(int i = 0; i<7;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1100+(200*i) ycoord:100]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2500+(200*i) ycoord:100]];
    }
    for(int i = 0; i<6;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2900+(200*i) ycoord:220]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:4100+(200*i) ycoord:220]];
    }
    for(int i = 0; i<7;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:5000+(200*i) ycoord:160]];
    }
    for(int i = 0; i<14;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:6400+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates:2600 p1:[unSwappablePlatforms objectAtIndex:1] x2:1100 p2:[unSwappablePlatforms objectAtIndex:0]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:4200 p1:[unSwappablePlatforms objectAtIndex:7] x2:4900 p2:[unSwappablePlatforms objectAtIndex:9]first:false]];
    [saws addObject:[[Saw alloc] initwithpoints:500 y:100 nextx:1000 nexty:100 speed:4.75 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1450 y:150 nextx:1450 nexty:55 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1700 y:100 nextx:2100 nexty:100 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3100 y:240 nextx:3700 nexty:240 speed:6.1 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3700 y:200 nextx:3100 nexty:200 speed:6 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:6300 y:190 nextx:5200 nexty:190 speed:7 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:6300 y:140 nextx:5200 nexty:140 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:6400 y:160 nextx:6900 nexty:160 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:7200 y:210 nextx:7200 nexty:110 speed:6 big:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2300 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2300 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3800 platform:[platforms objectAtIndex:11] swapvalue:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:7500 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel39//portals in the air
{
    [stars addObject:[[Star alloc]initwithcoordinates:900 ycoord:100 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1810 ycoord:290 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:4150 ycoord:60 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:200]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1250+(200*i) ycoord:200]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1925+(200*i) ycoord:200]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2700+(200*i) ycoord:160]];
    }
    for(int i = 0; i<13;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3700+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithxycoordinates:950 y1:200 x2:1150 p2:[platforms objectAtIndex:5]first:true]];
    [portals addObject:[[Portal alloc]initwithxycoordinates:2380 y1:70 x2:2600 p2:[unSwappablePlatforms objectAtIndex:0]first:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:350 platform:[platforms objectAtIndex:0] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:400 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:600 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1500 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1500 platform:[platforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1725 platform:[platforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2000 platform:[platforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1950 platform:[platforms objectAtIndex:8] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2200 platform:[platforms objectAtIndex:8] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3900 platform:[platforms objectAtIndex:10] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4000 platform:[platforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:4150 platform:[platforms objectAtIndex:10] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4300 platform:[platforms objectAtIndex:10] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4400 platform:[platforms objectAtIndex:10] swapvalue:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2900 y:190 nextx:3600 nexty:190 speed:6 big:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(true)];
    finish = [[FinishLine alloc]initwithcoordinates:4800 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel40
{
    [stars addObject:[[Star alloc]initwithcoordinates:300 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3000 ycoord:220 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3000 ycoord:100 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:90]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:700+(200*i) ycoord:90]];
    }
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1000+(200*i) ycoord:140]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2110+(200*i) ycoord:160]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2670+(200*i) ycoord:78]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2670+(200*i) ycoord:242]];
    }
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3575+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithxycoordinates:890 y1:250 x2:150 p2:[unSwappablePlatforms objectAtIndex:0]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:3700 p1:[platforms objectAtIndex:9] x2:2110 p2:[platforms objectAtIndex:8]first:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:400 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:550 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:500 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1100 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1100 platform:[platforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1250 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1400 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1400 platform:[platforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1550 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:3] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2700 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2850 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3150 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3300 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2700 platform:[unSwappablePlatforms objectAtIndex:9] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2900 platform:[unSwappablePlatforms objectAtIndex:9] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3100 platform:[unSwappablePlatforms objectAtIndex:9] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3300 platform:[unSwappablePlatforms objectAtIndex:9] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:4200 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel41
{
    [stars addObject:[[Star alloc]initwithcoordinates:1750 ycoord:50 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3000 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3775 ycoord:190 swapvalue:false]];
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:100]];
    }
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:1400+(200*i) ycoord:160]];
    }
    for(int i = 0; i<6;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:2525+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3725+(200*i) ycoord:160]];
    }
    for(int i = 0; i<16;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:4400+(200*i) ycoord:160]];
    }
    [portals addObject:[[Portal alloc]initwithxycoordinates:1175 y1:250 x2:1300 p2:[platforms objectAtIndex:5]first:true]];
    [portals addObject:[[Portal alloc]initwithcoordinates:3825 p1:[unSwappablePlatforms objectAtIndex:0] x2:4300 p2:[unSwappablePlatforms objectAtIndex:1]first:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:600 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:800 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:700 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1600 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1000 y:100 nextx:300 nexty:100 speed:4.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1750 y:120 nextx:1750 nexty:210 speed:6 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1900 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2000 platform:[platforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2150 platform:[platforms objectAtIndex:5] swapvalue:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:160 nextx:3400 nexty:160 speed:4.2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:160 nextx:2600 nexty:160 speed:4.2 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3000 platform:[platforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2800 platform:[platforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3200 platform:[platforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3000 platform:[platforms objectAtIndex:12] swapvalue:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:190 nextx:5400 nexty:190 speed:4.4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5400 y:190 nextx:4600 nexty:190 speed:4.4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:140 nextx:5400 nexty:140 speed:4.5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5400 y:140 nextx:4600 nexty:140 speed:4.5 big:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:5700 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel42
{
    [stars addObject:[[Star alloc]initwithcoordinates:600 ycoord:140 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2700 ycoord:180 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:4470 ycoord:80 swapvalue:false]];
    for(int i = 0; i<22;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<18;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:5200+(200*i) ycoord:160]];
    } 
    [portals addObject:[[Portal alloc]initwithcoordinates: 500 p1:[platforms objectAtIndex:0] x2:2100 p2:[platforms objectAtIndex:1]first:true]];
    [portals addObject:[[Portal alloc]initwithxycoordinates:4520 y1:70 x2:5100 p2:[unSwappablePlatforms objectAtIndex:0]first:false]];
    [saws addObject:[[Saw alloc] initwithpoints:650 y:160 nextx:1600 nexty:160 speed:5.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1600 y:160 nextx:650 nexty:160 speed:5.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:190 nextx:3200 nexty:190 speed:2.45 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:250 nextx:3200 nexty:250 speed:2.45 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2600 y:130 nextx:3200 nexty:130 speed:2.45 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:160 nextx:4100 nexty:160 speed:5.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4100 y:160 nextx:3400 nexty:160 speed:5.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5900 y:160 nextx:6700 nexty:160 speed:5.75 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:6700 y:160 nextx:5900 nexty:160 speed:5.75 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1800 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1900 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2000 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2400 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2450 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5350 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5500 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:5650 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:5450 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:5600 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5750 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:7100 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel43
{
    [stars addObject:[[Star alloc]initwithcoordinates:1400 ycoord:30 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:1500 ycoord:230 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:4950 ycoord:140 swapvalue:false]];
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:100+(200*i) ycoord:140]];
    } 
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1150+(200*i) ycoord:250]];
    } 
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:1150+(200*i) ycoord:90]];
    } 
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2100+(200*i) ycoord:170]];
    } 
    for(int i = 0; i<10;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2800+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<11;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:4800+(200*i) ycoord:160]];
    } 
    [portals addObject:[[Portal alloc]initwithcoordinates: 2300 p1:[unSwappablePlatforms objectAtIndex:16] x2:700 p2:[unSwappablePlatforms objectAtIndex:1]first:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1050 y:230 nextx:2050 nexty:230 speed:6.65 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2050 y:230 nextx:1050 nexty:230 speed:6.65 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2050 y:90 nextx:1050 nexty:90 speed:6.032 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2610 y:170 nextx:2690 nexty:160 speed:5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3200 y:130 nextx:4000 nexty:130 speed:5.95 big: false]];
    [saws addObject:[[Saw alloc] initwithpoints:4000 y:130 nextx:3200 nexty:130 speed:5.95 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5100 y:160 nextx:5100 nexty:160 speed:1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5100 y:100 nextx:5100 nexty:100 speed:1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:5100 y:40 nextx:5100 nexty:40 speed:1 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:400 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:600 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1400 platform:[unSwappablePlatforms objectAtIndex:13] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[unSwappablePlatforms objectAtIndex:13] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2850 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3000 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4200 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:4350 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4500 platform:[unSwappablePlatforms objectAtIndex:19] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(true)];
    finish = [[FinishLine alloc]initwithcoordinates:5600 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel44
{
    [stars addObject:[[Star alloc]initwithcoordinates:825 ycoord:70 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:3325 ycoord:250 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:6150 ycoord:30 swapvalue:false]];
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<11;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:975+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3175+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<10;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3500+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:5550+(200*i) ycoord:90]];
    }
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:6200+(200*i) ycoord:220]];
    } 
    for(int i = 0; i<5;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:7300+(200*i) ycoord:220]];
    } 
    for(int i = 0; i<11;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:8400+(200*i) ycoord:220]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:1050 y:160 nextx:1500 nexty:160 speed:6.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2100 y:130 nextx:2700 nexty:130 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2100 y:190 nextx:2700 nexty:190 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3325 y:210 nextx:3325 nexty:110 speed:3 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:160 nextx:5400 nexty:160 speed:6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3400 y:160 nextx:5400 nexty:160 speed:7 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5400 y:160 nextx:3400 nexty:160 speed:7 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:5450 y:90 nextx:6050 nexty:90 speed:5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:6100 y:200 nextx:7100 nexty:200 speed:6.1 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:7200 y:190 nextx:8200 nexty:190 speed:3.5 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:8200 y:190 nextx:7200 nexty:190 speed:3.5 big:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:400 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:500 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:775 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:775 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1400 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1575 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1650 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1800 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1800 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2150 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2300 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2450 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2500 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2600 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2650 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2750 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2800 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2900 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:2950 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5600 platform:[platforms objectAtIndex:17] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5900 platform:[platforms objectAtIndex:17] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:6400 platform:[unSwappablePlatforms objectAtIndex:12] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:6700 platform:[unSwappablePlatforms objectAtIndex:12] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:7000 platform:[unSwappablePlatforms objectAtIndex:12] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[platforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:9000 ycoord:200 swapvalue:false]; 
}
-(void) LoadLevel45
{
    [stars addObject:[[Star alloc]initwithcoordinates:350 ycoord:135 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:2050 ycoord:110 swapvalue:false]];
    [stars addObject:[[Star alloc]initwithcoordinates:7175 ycoord:195 swapvalue:false]];
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:50+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:650+(200*i) ycoord:160]];
    }
    for(int i = 0; i<6;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:925+(200*i) ycoord:160]];
    }
    for(int i = 0; i<6;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:2230+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:3430+(200*i) ycoord:160]];
    }
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3775+(200*i) ycoord:70]];
    }
    for(int i = 0; i<4;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:3775+(200*i) ycoord:240]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:4500+(200*i) ycoord:160]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:5050+(200*i) ycoord:90]];
    }
    for(int i = 0; i<6;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:6000+(200*i) ycoord:220]];
    }
    for(int i = 0; i<21;i++)
    {
        [platforms addObject:[[Platform alloc]initwithcoordinates:7200+(200*i) ycoord:220]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:8600+(200*i) ycoord:150]];
    }
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc]initwithcoordinates:8750+(200*i) ycoord:70]];
    }
    [portals addObject:[[Portal alloc]initwithcoordinates: 8850 p1:[unSwappablePlatforms objectAtIndex:24] x2:200 p2:[unSwappablePlatforms objectAtIndex:1]first:true]];
    [portals addObject:[[Portal alloc]initwithxycoordinates:5725 y1:230 x2:5900 p2:[unSwappablePlatforms objectAtIndex:20]first:false]];
    [saws addObject:[[Saw alloc] initwithpoints:1000 y:160 nextx:1800 nexty:160 speed:6.35 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:1800 y:160 nextx:1000 nexty:160 speed:6.35 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:2075 y:310 nextx:2075 nexty:10 speed:2.986 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:2075 y:10 nextx:2075 nexty:310 speed:2.986 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:3000 y:190 nextx:2600 nexty:190 speed:1.1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:3000 y:130 nextx:2600 nexty:130 speed:1.1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4475 y:70 nextx:3675 nexty:70 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4475 y:240 nextx:3675 nexty:240 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:250 nextx:5000 nexty:250 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:190 nextx:5000 nexty:190 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4600 y:130 nextx:5000 nexty:130 speed:4 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:4950 y:90 nextx:5550 nexty:90 speed:3.6 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:6400 y:200 nextx:7000 nexty:200 speed:5.5 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:7000 y:200 nextx:6400 nexty:200 speed:5.5 big:false]];
    for(int i = 0; i<8;i++)
    {
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:7250+(100*i) platform:[platforms objectAtIndex:18] swapvalue:true]];
    }
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:7350 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:7500 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:7650 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:7800 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:8050 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:8200 platform:[platforms objectAtIndex:18] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:8350 platform:[platforms objectAtIndex:18] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:725 platform:[platforms objectAtIndex:0] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:940 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:1600 platform:[platforms objectAtIndex:1] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:1700 platform:[platforms objectAtIndex:1] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2290 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2390 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:2490 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:3100 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:3150 platform:[unSwappablePlatforms objectAtIndex:5] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4000 platform:[unSwappablePlatforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:4200 platform:[unSwappablePlatforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:4000 platform:[unSwappablePlatforms objectAtIndex:16] swapvalue:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:4200 platform:[unSwappablePlatforms objectAtIndex:16] swapvalue:true]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:5300 platform:[platforms objectAtIndex:12] swapvalue:false]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:6200 platform:[unSwappablePlatforms objectAtIndex:20] swapvalue:true]];
    player = [[Player alloc]initwithcoordinates:100 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:(false)];
    finish = [[FinishLine alloc]initwithcoordinates:9400 ycoord:200 swapvalue:false]; 
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
