//
//  LongSpike.m
//  MyPlatformer
//
//  Created by Kirti Khanna on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LongSpike.h"
@implementation LongSpike
-(id) initwithcoordinates: (int) x platform: (Platform*) plat swapvalue:(bool) swap
{
    if((self=[super fileInitWithFrame:@"Spike_Long.png" swapvalue:swap]))
    {
        self.position= ccp(x,[plat giveHeight:self]);
    }
    return self;
}
-(CGRect) newboundingBox//change the width and height of this to make spikes easier/harder to collide with
{
    return CGRectMake(position_.x-20, position_.y-2 , 40, 4);
}
- (void) dealloc
{	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
