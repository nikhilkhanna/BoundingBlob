//
//  AppDelegate.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright Tangled Fire 2012. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "GameConfig.h"
#import "LevelScene.h"
#import "EndlessScene.h"
#import "MenuScene.h"
#import "LoadScene.h"
#import "MainMenuScene.h"
#import "RootViewController.h"
#import "iRate.h"
#import "Playtomic.h"
@implementation AppDelegate

@synthesize window;
@synthesize viewController;
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
    
    //	CC_ENABLE_DEFAULT_GL_STATES();
    //	CCDirector *director = [CCDirector sharedDirector];
    //	CGSize size = [director winSize];
    //	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
    //	sprite.position = ccp(size.width/2, size.height/2);
    //	sprite.rotation = -90;
    //	[sprite visit];
    //	[[director openGLView] swapBuffers];
    //	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"firstRun"])//if it is the first run
    {
        [defaults setObject:[NSDate date] forKey:@"firstRun"];//make it not hte first run
        for(int i = 1;i<46;i++)//init all level to -1 (not completed)
        {
            [defaults setInteger:-1 forKey:[NSString stringWithFormat:@"Level%d", i]];//making level 1-45, -1(has not completed)
        }
        [defaults setInteger:0 forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults]synchronize];//synch it 
    }
    [[Playtomic alloc]initWithGameId:951489 andGUID:@"8f8948ae2ed34b35" andAPIKey:@"f40117a865e24633ab0c562a59016d"];
    [[Playtomic Log]view];
    [[Playtomic Log]customMetricName:@"GameLaunched" andGroup:@"BasicActions" andUnique:NO];
    [iRate sharedInstance].appStoreID = 558312836;
    [iRate sharedInstance].appStoreGenreID = iRateAppStoreGameGenreID;
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 3;
    [iRate sharedInstance].remindPeriod = 2;
    [iRate sharedInstance].message = @"If you have enjoyed playing Bounding Blob please rate it 5 stars! Thanks for your support!";
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
    //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    //	if( ! [director enableRetinaDisplay:YES] )
    //		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	//[window addSubview: viewController.view];
    if([[UIDevice currentDevice].systemVersion floatValue]<6.0)
    {
        [window addSubview:viewController.view];
    }
    else
    {
        [window setRootViewController:viewController];
    }
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
    // LevelScene* scene = [[LevelScene alloc] init:1];//making a new scene(level scnee) and running it
	[[CCDirector sharedDirector] runWithScene: [[LoadScene alloc]init]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	if([[[CCDirector sharedDirector]runningScene] class]==[LevelScene class]||[[[CCDirector sharedDirector]runningScene] class]==[EndlessScene class])
    {
        [[[CCDirector sharedDirector] runningScene] pauseGame];//pauses game
    }
    else 
    {
        [[CCDirector sharedDirector] pause];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if(!([[[CCDirector sharedDirector]runningScene] class]==[LevelScene class]||[[[CCDirector sharedDirector]runningScene] class]==[EndlessScene class]))
    {
        [[CCDirector sharedDirector] resume];   
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
