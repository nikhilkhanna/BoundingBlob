//
//  LevelSelect.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/30/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "AdWhirlView.h"
#import "AdWhirlDelegateProtocol.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface LevelSelect : CCLayer <AdWhirlDelegate>
{
    RootViewController *viewController;
    AdWhirlView *adWhirlView;
}
-(id) init: (int) initlevelnum;
-(int) levelNumber;
-(void) goingBack;
-(bool) back;
@property(nonatomic, retain) AdWhirlView *adWhirlView;
@end