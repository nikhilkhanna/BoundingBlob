//
//  WinLayer.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface WinLayer : CCLayerColor<AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) WinInit: (int) starscollected maxlevel:(int) max current: (int) currentLevel;
-(bool) goToLevelSelect;
-(bool) goToNext;
-(bool) goToReplay;
-(void) makeStarHolder;
@property(nonatomic,retain) AdWhirlView *adWhirlView;
@end
