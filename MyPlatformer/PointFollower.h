//
//  PointFollower.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/8/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "cocos2d.h"
@interface PointFollower : CCSprite
-(id) initWithPoint:(CGPoint) point;
-(void) updateCameraPosition: (int) correctionFactor;
-(void) EndlessUpdate;
@end
