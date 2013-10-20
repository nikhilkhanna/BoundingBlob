//
//  EndlessModeOver.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface EndlessModeOver : CCLayerColor<AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) init: (int) score;
-(bool) goToMenu;
-(bool) goToReplay;
@property(nonatomic,retain) AdWhirlView *adWhirlView;
@end
