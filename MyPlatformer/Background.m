//
//  Background.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Background.h"
#include <stdlib.h>
int mySection;
@implementation Background
-(id) initwithcoordinates: (int) section firstbackground: (bool) first
{
    mySection = section;
    NSMutableString* filename;
    int rand;
    if(section==1)//getting the file names based on the section + random number
    {
        rand = (arc4random() % 3) + 1;
        filename = [NSMutableString stringWithFormat:@">Grassland_MID_%d.png",rand]; 
    }
    else if (section==2)
    {
        rand = (arc4random() % 5) + 1;
        filename = [NSMutableString stringWithFormat:@"City_MID_%d.png",rand];
    }
    else if (section==3)//tmp
    {
        rand = (arc4random() % 5) + 1;
        filename = [NSMutableString stringWithFormat:@"Mars_MID_%d.png",rand];
    }
    if((self = [super initWithSpriteFrameName:filename]))
    {
        if(first)
            self.position = ccp([self halfwidth], [self halfheight]);
        else 
        {
            self.position = ccp([self halfwidth]+[self width], [self halfheight]);
        }
    }
    return self;
}
-(void) updateCameraPosition:(int)correctionFactor
{
    self.position= ccp(self.position.x+1.5, self.position.y);
}
-(void) Update
{
    self.position=ccp(position_.x-1.5, position_.y);
    if([self isOffScreen])
    {
        if(mySection!=1)
        self.position=ccp(480+[self halfwidth], self.position.y);
        else
        self.position=ccp(480+[self width], self.position.y);
    }
}
@end
