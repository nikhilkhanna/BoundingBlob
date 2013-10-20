//
//  Spike.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@class Platform;
@interface Spike : SwappableCCSprite
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap;
@end
