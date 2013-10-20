//
//  StarHolder.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwappableCCSprite.h"
@interface StarHolder : SwappableCCSprite
{
    @public id noneToOne;
    @public id oneToTwo;
    @public id twoToThree;
}
-(id)initWithFrame;
-(void) Animate: (int) numStars;
@end
