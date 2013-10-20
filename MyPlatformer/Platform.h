//
//  Platform.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/28/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@class Player;
@interface Platform : CCSprite
//gives sprite the height their origin should be at if they want to be on the platform assuming platform is line
-(CGFloat) giveHeight: (SwappableCCSprite*) sprite;
-(CGFloat) width;
-(CGFloat) height;
-(CGFloat) halfwidth;
-(CGFloat) halfheight;
-(void) Update;
-(id) initwithcoordinates: (int) x ycoord: (int) y;
-(bool) stopSprite:(Player*)player;
-(bool) isOffScreen;
-(void) updateCameraPosition: (int) correctionFactor;
-(void) EndlessUpdate;
-(void) setX: (CGFloat) x;
@end
