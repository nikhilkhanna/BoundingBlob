//
//  Spike.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@class Platform;
@interface Spike : SwappableCCSprite
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap;
@end
