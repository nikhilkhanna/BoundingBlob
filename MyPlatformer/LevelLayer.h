//
//  LevelLayer.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "cocos2d.h"
#import "CCTouchDispatcher.h"
#import "Player.h"
@interface LevelLayer : CCLayerColor<AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) levelinit: (int) levelnum;
-(bool) playerIsDead;
-(bool) playerWin;
-(int) starsCollected;
-(bool) menu;
-(bool) paused;
-(void) Pause;
@property (nonatomic, retain)AdWhirlView *adWhirlView;
@end
