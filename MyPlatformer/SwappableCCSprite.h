//
//  SwappableCCSprite.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "cocos2d.h"
@class Platform;
#import <Foundation/Foundation.h>
@interface SwappableCCSprite : CCSprite
{
    @public bool Swapped;
}
-(bool) SwappableCollision: (SwappableCCSprite*) s;
-(id) init;
-(id) fileInit:(NSString*) name swapvalue: (bool) myswapvalue; 
-(id) fileInitWithFrame:(NSString*) name swapvalue: (bool) myswapvalue;
-(CGFloat) width;
-(CGFloat) height;
-(CGFloat) halfwidth;
-(CGFloat) halfheight;
-(void) Update;
-(bool) isOffScreen;
-(bool) Intersects:(SwappableCCSprite*) sprite;
-(bool) IntersectsIgnoreSwap:(CCSprite*)sprite;
-(bool) IntersectsIgnoreSwapSwappableSprite:(SwappableCCSprite*)sprite;
-(bool) isSwapped;
-(bool) isOn:(Platform*) platform;
-(bool) isAlignedX:(Platform*) platform;
-(CGRect) newboundingBox;// to change collision overload this method with a collision rect(see spike for example)
-(void) updateCameraPosition: (int) correctionFactor;
-(void) VisiblityUpdate;
-(void) setX: (CGFloat) x;
-(void) EndlessUpdate;
-(bool) isOffScreenRight;
-(bool)isInView;
@end
