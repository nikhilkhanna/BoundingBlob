//
//  FinishLine.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@interface FinishLine : SwappableCCSprite 
-(id) initwithcoordinates: (int) x ycoord: (int) y swapvalue:(bool) swap;
@end
