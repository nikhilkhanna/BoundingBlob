//
//  MenuScene.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/30/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface MenuScene : CCScene//contains level select and other "menus"
-(id) init: (int) levelnum;
-(int) LevelNumber;
-(void) goBack;
@end
