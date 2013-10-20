//
//  Saw.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
#import "SimpleAudioEngine.h"
@interface Saw : SwappableCCSprite
{
    bool goingtopoint2;
    float speed;
    bool big;
    CGPoint point1;
    CGPoint point2;
    CCAction* sawSpinAction;
    bool playingLoop;
    ALuint spinSound;
}
-(id) initwithpoints: (int) x1 y: (int) y1 nextx:(int) x2 nexty: (int) y2 speed: (float) mySpeed big: (bool) isBig;
-(void) Update;
-(bool) isOffScreen;
-(CGPoint) point1;
-(CGPoint) point2;
-(bool) isBig;
-(void) spinAction;
-(void) deadUpdate;
-(ALuint) getSpinSound;
-(void) stopSpinSound;
@end
