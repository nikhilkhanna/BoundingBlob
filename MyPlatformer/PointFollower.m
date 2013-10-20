//
//  PointFollower.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/8/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "PointFollower.h"

@implementation PointFollower
-(id) initWithPoint:(CGPoint) point
{
    if(self = [super initWithSpriteFrameName:@"node.png"])
    {
        self.position = point;
        [self setScale:1.5];
    }
    return self;
}
-(CGFloat) width
{
    return self.boundingBox.size.width;
}

-(CGFloat) height
{
    return self.boundingBox.size.height;
}
-(CGFloat) halfwidth
{
    return [self width]/2;
}
-(CGFloat) halfheight
{
    return [self height]/2;
}
-(bool) isOffScreen
{
    if (self.position.x<-50)
    {
        return true;
    }
    return false;
}
-(void) Update
{
    self.position = ccp(self.position.x-3, self.position.y);
    [self VisiblityUpdate];
}
-(void) EndlessUpdate
{
    [self VisiblityUpdate];
}
-(void) VisiblityUpdate
{
    if(self.position.x<0-[self halfwidth]-1||self.position.x>480+[self halfwidth]+1)
    {
        self.visible = NO;
    }
    else 
    {
        self.visible = YES;
    }
}
-(void) updateCameraPosition: (int) correctionFactor
{
    self.position = ccp(self.position.x+correctionFactor, self.position.y);
}
@end
