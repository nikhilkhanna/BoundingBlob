//
//  FinishLine.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "FinishLine.h"

@implementation FinishLine
-(id) initwithcoordinates: (int) x ycoord: (int) y swapvalue:(bool) swap
{
    if((self=[super fileInitWithFrame:@"Finish_Line.png" swapvalue:swap]))
    {
          self.position= ccp(x,y-40);
    }
    return self;
}
-(void) Update//delete this when asset comes else use this to prevent lag
{
    [super Update];
}
- (void) dealloc
{	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
