//
//  Star.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@interface Star : SwappableCCSprite
{
    bool isDeleted;
    CCAction* starTurnAction;
    CCAction* starDeleteAction;
}
-(id) initwithcoordinates: (int) x ycoord: (int) y swapvalue:(bool) swap;
-(void) selfdelete;
-(bool) Deleted;
-(void) turn;
-(void) dissappear;
@end
