//
//  Chunk.h
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/31/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
@interface Chunk : CCNode
{
    @public NSMutableArray* spikes;
   @public  NSMutableArray* stars;
   @public  NSMutableArray* platforms;
    @public NSMutableArray* unSwappablePlatforms;
    @public NSMutableArray* saws;
   @public NSMutableArray* nodes;
    int ChuckCoordinate;
}
-(id) initWithChunkNum: (int) chunkNum;
-(void) Update: (Player*) player;
-(bool) OffScreen;
@end
