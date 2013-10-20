//
//  Player.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "SwappableCCSprite.h"
#import "SimpleAudioEngine.h"
@class FinishLine;
#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface Player:SwappableCCSprite
{
    CCAction* walkAction;
    CCAction* jumpAction;
    CCAction* dieAction;
}
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap;
-(void) playerJump;
-(void) playerSwap;
-(void) playerStopJump;
-(void) Update: (NSMutableArray*) platforms unswappableplats: (NSMutableArray*) unswappableplatforms spike: (NSMutableArray*) spikes saw: (NSMutableArray*) saws;
-(bool) getJumping;
-(bool) getFalling;
-(bool) isDead: (NSMutableArray*) spikes sawarray: (NSMutableArray*) saws;
-(bool) isWinner: (FinishLine*) finish;
-(void) JumpButtonUp;
-(ALuint) getRunEffect;
-(void) startRunEffect;
-(bool) getDead;
@end
