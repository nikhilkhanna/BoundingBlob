//
//  UnswappablePlatform.m
//  MyPlatformer
//
//  Created by Kirti Khanna on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UnswappablePlatform.h"

@implementation UnswappablePlatform
-(id) initwithcoordinates: (int) x ycoord: (int) y
{
    if((self = [super initWithSpriteFrameName:@"Iron_Platform.png"]))
    {
        self.position = ccp(x, y);
    }
    return self;
}
-(void)dealloc
{
    [super dealloc];
}
@end
