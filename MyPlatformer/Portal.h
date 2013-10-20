//
//  Portal.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@class Platform;
@class Player;
@interface Portal : SwappableCCSprite
{
    SwappableCCSprite* portal2;
    id Portal1animation;
    id Portal2animation;
}
-(id) initwithcoordinates: (int) x1 p1: (Platform*) plat1 x2: (int) x2 p2: (Platform*) plat2 first: (bool) isFirst;
-(id) initwithxycoordinates: (int) x1 y1: (int) y1 x2: (int) x2 p2: (Platform*) plat2 first: (bool) isFirst;
-(bool) teleportPlayer: (Player*) p;
-(void) Update;
-(SwappableCCSprite*) portal2;
@end
