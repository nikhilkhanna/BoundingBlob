//
//  EndlessModeMenu.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface EndlessModeMenu : CCScene<AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) init;
-(void) play;
-(void) goBack;
@property(nonatomic, retain) AdWhirlView *adWhirlView;
@end
