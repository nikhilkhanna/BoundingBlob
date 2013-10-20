//
//  Spike.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/27/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Spike.h"
#import "Platform.h"
@implementation Spike
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap
{
    if((self=[super fileInitWithFrame:@">Spike_Regular.png" swapvalue:swap]))
    {
        self.position= ccp(x,[plat giveHeight:self]);
    }
    return self;
}
- (void) dealloc
{	
	// don't forget to call "super dealloc"
	[super dealloc];
}
-(CGRect) newboundingBox//change the width and height of this to make spikes easier/harder to collide with
{
    return CGRectMake(position_.x-9, position_.y-2, 18, 5);
}
@end
