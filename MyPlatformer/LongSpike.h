//
//  LongSpike.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/3/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spike.h"
#import "Platform.h"
@interface LongSpike : Spike
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap;
@end
