//
//  SlideHolder.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ButtonSlide.h"
@interface SlideHolder : CCSprite
-(id) initWithArray: (NSMutableArray*) slides;
-(int) level;
@end
