//
//  ButtonSlide.h
//  ;
//
//  Created by Nikhil Khanna on 7/25/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface ButtonSlide : CCSprite//a slide that holds buttons
-(id) initwithbuttons: (int) firstbutton size: (int) numbuttons;//usually numbuttons is 15
-(int) currentLevelNumber;
-(void) setPosition: (int) x ycoordinate: (int) y;
-(CGPoint) getPosition;
@end
