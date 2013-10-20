//
//  Star.h
//  MyPlatformer
//
//  Created by Kirti Khanna on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
