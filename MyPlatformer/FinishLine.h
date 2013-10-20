//
//  FinishLine.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@interface FinishLine : SwappableCCSprite 
-(id) initwithcoordinates: (int) x ycoord: (int) y swapvalue:(bool) swap;
@end
