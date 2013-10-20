//
//  FarBackground.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/29/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "FarBackground.h"

@implementation FarBackground
int mySection;
-(id) initwithcoordinates: (int) section firstbackground: (bool) first
{
    mySection = section;
    NSMutableString* file_name;
    int rand;
    if(section==1)//getting the file names based on the section + random number
    {
        rand = (arc4random() % 2) + 1;
        file_name = [NSMutableString stringWithFormat:@">Grassland_BG_%d.png",rand]; 
    }
    else if (section==2)
    {
        rand = (arc4random()%3)+1;
        file_name = [NSMutableString stringWithFormat:@"City_BG_%d.png",rand]; 
    }
    else if (section==3)//tmp
    {
        rand = (arc4random()%3)+1;
        file_name = [NSMutableString stringWithFormat:@"Mars_BG_%d.png",rand]; 
    }
    if((self = [super initWithSpriteFrameName:file_name]))
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
-(void) Update
{
    self.position=ccp(position_.x-(.75), position_.y);
    if([self isOffScreen])
    {
        if(mySection!=1)
            self.position=ccp(480+[self halfwidth]-1, self.position.y);
        else
            self.position=ccp(480+[self width], self.position.y);
    }
}
-(void) updateCameraPosition: (int) correctionFactor
{
    self.position = ccp(self.position.x+(.75), self.position.y);
}
@end
