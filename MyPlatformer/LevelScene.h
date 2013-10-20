//
//  LevelScene.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelLayer.h"
@interface LevelScene : CCScene//contains the level layers and the layers for the win screen
-(id) init: (int) levelnumber;
-(void) pauseGame;
@end
