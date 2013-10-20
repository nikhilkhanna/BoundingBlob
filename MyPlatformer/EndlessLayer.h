//
//  EndlessLayer.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "cocos2d.h"
@interface EndlessLayer  : CCLayerColor<AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) init;
-(bool) menu;
-(bool) lost;
-(int)score;
-(void) Pause;
-(bool) paused;
@property (nonatomic, retain)AdWhirlView *adWhirlView;
@end
