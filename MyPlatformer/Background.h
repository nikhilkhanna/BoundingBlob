//
//  Background.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@interface Background : SwappableCCSprite 
-(id) initwithcoordinates: (int) section firstbackground: (bool) first;//section is 1,2, or 3 based on where it is in the level used to change background file
-(void) Update;//moves the sprite
-(void) updateCameraPosition: (int) correctionFactor;
@end
