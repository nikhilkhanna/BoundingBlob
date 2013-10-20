//
//  Chunk.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/31/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Chunk.h"
#import "Platform.h"
#import "Star.h"
#import "Spike.h"
#import "LongSpike.h"
#import "Saw.h"
#import "PointFollower.h"
#import "UnswappablePlatform.h"
@implementation Chunk
int myChunkNumber;
int ChunkSize = 960;//width of a chunk
const static int regular = 960;
const static int large = 1920;
-(id) initWithChunkNum: (int) chunkNum//first chunk is always chunk 1 adjust acoordingly
{
    if((self = [super init]))
    {
        ChunkSize = regular;
        myChunkNumber = chunkNum;
        if(myChunkNumber == 1)//might change initial position if coordinates are wrong.
        {
            self->ChuckCoordinate = 0;//the left side of the thing(the number added to positiions)
        }
        else 
        {
            self->ChuckCoordinate = ChunkSize;
        }
        [self LoadChunk];
    }
    return self;
}
-(void) Update: (Player*) player
{
    self->ChuckCoordinate-=3;
    [self UpdateObjects: player];
}
-(void) UpdateObjects: (Player*) player
{
    for(int i = 0; i<[spikes count];i++)
    {
        [[spikes objectAtIndex:i]Update];
    }
    for(int i = 0; i<[stars count];i++)
    {
        [[stars objectAtIndex:i]Update];
    }
    for(int i = 0; i<[platforms count];i++)
    {
        [[platforms objectAtIndex:i]Update];
    }
    for(int i = 0; i<[unSwappablePlatforms count];i++)
    {
        [[unSwappablePlatforms objectAtIndex:i]Update];
    }
    for(int i = 0; i<[saws count];i++)
    {
        [[saws objectAtIndex:i] Update];
    }
    for (int i = 0; i<[nodes count]; i++) 
    {
        [[nodes objectAtIndex:i] Update];
    }
}
-(void) DeleteObjects: (Player*) player
{
    for(int i = 0; i<[stars count];i++)
    {
        if([[stars objectAtIndex:i]isOffScreen])
        {
            [stars removeObjectAtIndex:i];
            break;
        }
    } 
    for(int i = 0; i<[spikes count]; i++)//removes offscreen spikes
    {
        if([[spikes objectAtIndex:i]isOffScreen])
        {
            [spikes removeObjectAtIndex:i];
            break;//breaks so array traversal isn't f'ed
        }
    }
    for(int i = 0; i<[platforms count];i++)
    {
        if([[platforms objectAtIndex:i]isOffScreen])
        {
            [platforms removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[unSwappablePlatforms count];i++)
    {
        if([[unSwappablePlatforms objectAtIndex:i]isOffScreen])
        {
            [unSwappablePlatforms removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[saws count];i++)
    {
        if([[saws objectAtIndex:i]isOffScreen])
        {
            [saws removeObjectAtIndex:i];
            break;
        }
    }
    for(int i = 0; i<[nodes count];i++)
    {
        if ([[nodes objectAtIndex:i]isOffScreen])
        {
            [nodes removeObjectAtIndex:i];
            break;
        }
    }
}
-(void) empty
{
    // don't forget to call "super dealloc"
    [self removeAllChildrenWithCleanup:YES];
    [spikes removeAllObjects];
    [spikes release];
    spikes = nil;
    [platforms removeAllObjects];
    [platforms release];
    platforms = nil;
    [unSwappablePlatforms removeAllObjects];
    [unSwappablePlatforms release];
    unSwappablePlatforms = nil;
    [nodes removeAllObjects];
    [nodes release];
    nodes = nil;
    [saws removeAllObjects];
    [saws release];
    saws = nil;
    [stars removeAllObjects];
    [stars release];
    stars = nil;
}
-(void) dealloc
{
    [self empty];
    ChuckCoordinate = ChunkSize;
    [super dealloc];
}
-(void) LoadChunk//calls methods to load chunks
{
    platforms = [[NSMutableArray alloc] init];
    unSwappablePlatforms = [[NSMutableArray alloc] init];
    spikes = [[NSMutableArray alloc] init];
    stars = [[NSMutableArray alloc] init];
    saws = [[NSMutableArray alloc] init];
    nodes = [[NSMutableArray alloc] init];
    [self addObjects];
    [self makeNodes];
}
-(void) addChildren//makes children
{
    for(int i = 0; i<spikes.count; i++)//adding spikes
    {
        [self addChild:[spikes objectAtIndex:i]];
    }
    for(int i = 0; i<stars.count; i++)//and stars
    {
        [self addChild:[stars objectAtIndex:i]];
       // [[stars objectAtIndex:i] runAction:[[starTurnAction copy] autorelease]];
    }
    for(int i = 0; i<platforms.count; i++)
    {
        [self addChild:[platforms objectAtIndex:i]];
    }
    for(int i = 0; i<unSwappablePlatforms.count; i++)//and stars
    {
        [self addChild:[unSwappablePlatforms objectAtIndex:i]];
    }
    for(int i = 0; i<saws.count;i++)
    {
        [self addChild:[saws objectAtIndex:i]];
//        if ([[saws objectAtIndex:i] isBig])
//        {
//            [[saws objectAtIndex:i] runAction:[[largeSawTurnAction copy] autorelease]];
//        }
//        else 
//        {
//            [[saws objectAtIndex:i] runAction:[[smallSawTurnAction copy] autorelease]];
//        }
    }
    for (int i = 0; i<nodes.count; i++)
    {
        [self addChild:[nodes objectAtIndex:i]];
    }
}
-(void) makeNodes//adds nodes to node arrays
{
    for(int i = 0; i<saws.count;i++)
    {
        CGPoint point1 = [[saws objectAtIndex:i]point1];
        CGPoint point2 = [[saws objectAtIndex:i]point2];
        [nodes addObject:[[PointFollower alloc]initWithPoint:point1]];
        [nodes addObject:[[PointFollower alloc]initWithPoint:point2]];
    }
}
-(bool)OffScreen
{
    if (self->ChuckCoordinate<=-ChunkSize) 
    {
        return true;
    }
    return false;
}
-(void) addObjects//sets up the arrays with the right objects
{
    if(myChunkNumber<3)
    {
        [self starter];
    }
    else if (myChunkNumber<7)
    {
        if(arc4random() % 100<35)
        {
            [self starter];
        }
        else 
        {
            [self easy];
        }
    }
    else if(myChunkNumber<13)
    {
        int rand = arc4random();
        if(rand % 100<10)
        {
            [self starter];
        }
        else if(rand % 100<40)
        {
            [self easy];
        }
        else if(rand%100<92)
        {
            [self medium];
        }
        else
        {
            [self hard];
        }
    }
    else 
    {
        int rand = arc4random();
        if(rand % 100<5)
        {
            [self starter];
        }
        else if(rand % 100<15)
        {
            [self easy];
        }
        else if(rand % 100<55)
        {
            [self medium];
        }
        else
        {
            [self hard];
        }
    }
}
-(void) starter
{
    int rand = (arc4random() % 5) + 1;
    switch (rand)
    {
        case 1:
            [self starter1];
            break;
        case 2:
            [self starter2];
            break;
        case 3:
            [self starter3];
            break;
        case 4:
            [self starter4];
            break;
        case 5:
            [self starter5];
            break;
        default:
            break;
    }
    
}
-(void) easy
{
    int rand = (arc4random() % 5) + 1;
    switch (rand)
    {
        case 1:
            [self easy1];
            break;
        case 2:
            [self easy2];
            break;
        case 3:
            [self easy3];
            break;
        case 4:
            [self easy4];
            break;
        case 5:
            [self easy5];
            break;
        default:
            break;
    }
}
-(void) medium
{
    int rand = (arc4random() % 5) + 1;
    switch (rand)
    {
        case 1:
            [self medium1];
            break;
        case 2:
            [self medium2];
            break;
        case 3:
            [self medium3];
            break;
        case 4:
            [self medium4];
            break;
        case 5:
            [self medium5];
            break;
        default:
            break;
    }
}
-(void) hard
{
    int rand = (arc4random() % 5) + 1;
    switch (rand)
    {
        case 1:
            [self hard1];
            break;
        case 2:
            [self hard2];
            break;
        case 3:
            [self hard3];
            break;
        case 4:
            [self hard4];
            break;
        case 5:
            [self hard5];
            break;
        default:
            break;
    }
}
//levelloadingmethods below
-(void) starter1
{
    int rand = (arc4random() % 2);
    int height = 160;
    if(rand==0)
    {
        height = 240;
    }
    else
    {
        height = 80;
    }
    for(int i = 0; i <2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }
    for(int i = 0; i <2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 600+(200*i) ycoord:160]];
    } 
    if(arc4random()%100<25)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+450 ycoord:height swapvalue:false]];
    }
}
-(void) starter2
{
    int rand = (arc4random() % 2);
    int rand2  = (arc4random() % 2);
    int rand3 = (arc4random() % 2);
    int height = 160;
    if(rand2==0)
    {
        height = 250;
    }
    else
    {
        height = 70;
    }
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }
    [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 800 ycoord:160]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 500 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 625 platform:[platforms objectAtIndex:2] swapvalue:rand2]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 750 platform:[platforms objectAtIndex:2] swapvalue:rand3]];
    if(arc4random()%100<10)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+625 ycoord:height swapvalue:false]];
    }
}
-(void) starter3
{
   int rand = (arc4random() % 2) + 1;
    int height = 160;
    if (rand==1)
    {
        height = 100;
    }
    else
    {
        height = 220;
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:height]];
    }
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:160]];
    }
}
-(void) starter4
{
    int rand = (arc4random() % 2);
    int height = 160;
    if(rand==0)
    {
        height = 240;
    }
    else
    {
        height = 80;
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 600+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 700 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+700 ycoord:height swapvalue:false]];
    }
}
-(void) starter5
{
    int rand = (arc4random() % 2);
    int height1 = 160;
    int height2 = 160;
    int starheight = 160;
    if(rand==0)
    {
        height1 = 100;
        height2 = 200;
    }
    else
    {
        height1 = 200;
        height2 = 100;
    }
    starheight = height2-30;
    if(arc4random()%100<15)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+650 ycoord:starheight swapvalue:false]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:height1]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 600+(200*i) ycoord:height2]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 800+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 800 platform:[platforms objectAtIndex:4] swapvalue:rand]];
}
-(void) easy1
{
    bool swapped;
    int rand = (arc4random() % 3);
    if(rand<1)
    {
        swapped = true;
    }
    else
    {
        swapped = false;
    }
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 800+(200*i) ycoord:160]];
    }
    for(int i = 0; i<5;i++)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 250+(50*i) platform:[platforms objectAtIndex:0] swapvalue:swapped]];
    }
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 300 platform:[platforms objectAtIndex:0] swapvalue:!swapped]];
}
-(void) easy2
{
    int rand = (arc4random() % 3);
    int first; 
    int second;
    if(rand<2)
    {
        first = 90;
        second = 220;
    }
    else
    {
        first = 220; 
        second = 90;
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:first]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 300+(200*i) ycoord: second]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 650+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 500 platform:[platforms objectAtIndex:2] swapvalue:false]];
}
-(void) easy3
{
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+350 ycoord:70 swapvalue:false]];
    }
    int rand = (arc4random() % 2);
    int rand2 = (arc4random() % 2);
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 800+(200*i) ycoord:160]];
    }
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 200 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 350 platform:[platforms objectAtIndex:2] swapvalue:!rand]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 500 platform:[platforms objectAtIndex:2] swapvalue:rand2]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 500 platform:[platforms objectAtIndex:2] swapvalue:!rand2]];
}
-(void) easy4
{
    int rand = (arc4random() % 2);
    int height1;
    int height2;
    if(rand==0)
    {
        height1 = 90;
        height2 = 220;
    }
    else 
    {
        height1 = 220;
        height2 = 90;
    }
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+775 ycoord:height2-60 swapvalue:false]];
    }
    int rand2 = (arc4random() %2);
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:height1]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 325+(200*i) ycoord:160]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 750+(200*i) ycoord:height2]];
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 800+(200*i) ycoord:height2]];
    }
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 375 platform:[platforms objectAtIndex:2] swapvalue:!rand2]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 525 platform:[platforms objectAtIndex:2] swapvalue:rand2]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 775 platform:[platforms objectAtIndex:3] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 775 platform:[platforms objectAtIndex:3] swapvalue:true]];
}
-(void) easy5
{
    int rand = (arc4random() %2);
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 350+(200*i) ycoord:240]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 350+(200*i) ycoord:80]];
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 660+(200*i) ycoord:160]];
    } 
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 400 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 450 platform:[platforms objectAtIndex:2] swapvalue:!rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 550 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 600 platform:[platforms objectAtIndex:2] swapvalue:!rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 400 platform:[platforms objectAtIndex:3] swapvalue:!rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 450 platform:[platforms objectAtIndex:3] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 550 platform:[platforms objectAtIndex:3] swapvalue:!rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 600 platform:[platforms objectAtIndex:3] swapvalue:rand]];
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 800 platform:[platforms objectAtIndex:6] swapvalue:false]];
    if(arc4random()%100<40)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+450 ycoord:160 swapvalue:false]];
    }
}
-(void) medium1
{
    int rand = (arc4random()%2);
    int firstheight;
    int secondheight;
    if(rand ==0)
    {
        firstheight = 220;
        secondheight = 90;
    }
    else
    {
        firstheight = 90;
        secondheight = 220;
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:firstheight]];
    } 
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:secondheight]];
    } 
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 630+(200*i) ycoord:secondheight]];
    } 
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 860+(200*i) ycoord:160]];
    } 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 500 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 650 platform:[unSwappablePlatforms objectAtIndex:0] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 860 platform:[platforms objectAtIndex:2] swapvalue:rand]];
    if(arc4random()%100<25)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+860 ycoord:70 swapvalue:false]];
    }
}
-(void) medium2
{
    int rand = (arc4random()%2);
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 500+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 860+(200*i) ycoord:160]];
    } 
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 100 platform:[platforms objectAtIndex:1] swapvalue:rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 200 platform:[platforms objectAtIndex:1] swapvalue:!rand]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 300 platform:[platforms objectAtIndex:1] swapvalue:rand]];
    for(int i = 0; i<5;i++)
    {
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 500+(50*i) platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:!rand]]; 
    }
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 700 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:rand]]; 
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+360 ycoord:130 swapvalue:false]];
    }
}
-(void) medium3
{
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:75]];
    } 
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:245]];
    } 
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 860+(200*i) ycoord:160]];
    } 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 425 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]]; 
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 625 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]]; 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 775 platform:[unSwappablePlatforms objectAtIndex:1] swapvalue:false]]; 
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 425 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]]; 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 625 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]]; 
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 775 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]]; 
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+625 ycoord:160 swapvalue:false]];
    }
}
-(void) medium4
{
    int rand = (arc4random()%2);
    int rand2 = (arc4random()%2);
    int rand3 = (arc4random()%6);
    int height;
    if(rand)
    {
        height = 70;
    }
    else
    {
        height = 250;
    }
    rand3 = 2+rand3/10;
    for(int i = 0; i<5;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 60+(200*i) ycoord:160]];
    }  
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 125 platform:[platforms objectAtIndex:0] swapvalue:rand]]; 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 250 platform:[platforms objectAtIndex:0] swapvalue:!rand]]; 
    [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 375 platform:[platforms objectAtIndex:0] swapvalue:rand]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 425 y: 160 nextx:self->ChuckCoordinate + 900 nexty:160 speed:rand3 big:rand2]];
    if(arc4random()%100<20)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+250 ycoord:height swapvalue:false]];
    }
}
-(void) medium5
{
    int rand = (arc4random()%2);
    int height;
    int sawheight;
    int sawheight2;
    if(rand ==0)
    {
        height = 90;
    }
    else
    {
        height = 230;
    }
    if(arc4random()%2)
    {
        sawheight = 70;
        sawheight2 = 250;
    }
    else
    {
        sawheight = 250;
        sawheight2 = 70;
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 50+(200*i) ycoord:height]];
    }  
    for(int i = 0; i<4;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 200+(200*i) ycoord:160]];
    } 
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 400 y: sawheight nextx:self->ChuckCoordinate + 400 nexty:sawheight2 speed:2 big:false]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 600 y: sawheight2 nextx:self->ChuckCoordinate + 600 nexty:sawheight speed:3 big:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 750 platform:[platforms objectAtIndex:2] swapvalue:false]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 750 platform:[platforms objectAtIndex:2] swapvalue:true]];
    if(arc4random()%100<15)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+750 ycoord:70 swapvalue:false]];
    }
}
-(void) hard1
{
    int rand = (arc4random()%2);
    int rand2 = (arc4random()%11);
    rand2 = rand2/10;
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    }  
    for(int i = 0; i<3;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 300+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<1;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 800+(200*i) ycoord:160]];
    } 
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 300 y: 130 nextx:self->ChuckCoordinate + 800 nexty:130 speed:rand2+2.5 big:rand]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 800 y: 190 nextx:self->ChuckCoordinate + 300 nexty:190 speed:rand2+2.5 big:rand]];
    if(arc4random()%100<25)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+230 ycoord:130 swapvalue:false]];
    }
}
-(void) hard2
{
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 100+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<3;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:160]];
    } 
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 300 y: 160 nextx:self->ChuckCoordinate + 800 nexty:160 speed:4.1 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 800 y: 160 nextx:self->ChuckCoordinate + 300 nexty:160 speed:4.1 big:true]];
    [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 645 platform:[platforms objectAtIndex:2] swapvalue:false]];
    if(arc4random()%100<50)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 645 platform:[platforms objectAtIndex:2] swapvalue:true]];
    }
    if(arc4random()%100<50)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 475 platform:[platforms objectAtIndex:2] swapvalue:false]];
    }
    if(arc4random()%100<30)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+645 ycoord:230 swapvalue:false]];
    }
}
-(void) hard3
{
    int rand = (arc4random()%2);
    int rand2 = (arc4random()%2);
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 60+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:80]];
    } 
    [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 750 ycoord:80]];
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 400+(200*i) ycoord:240]];
    } 
    [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 750 ycoord:240]];
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 850+(200*i) ycoord:160]];
    } 
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 300 y: 240 nextx:self->ChuckCoordinate + 850 nexty:240 speed:4.1 big:rand]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 300 y: 80 nextx:self->ChuckCoordinate + 850 nexty:80 speed:4.1 big:rand2]];
    if(arc4random()%100<50)
    {
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 525 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]];
    }
    else 
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 525 platform:[unSwappablePlatforms objectAtIndex:4] swapvalue:true]];
    }
        [spikes addObject:[[LongSpike alloc] initwithcoordinates:self->ChuckCoordinate + 525 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    if(arc4random()%100<30)
    {
        [spikes addObject:[[Spike alloc] initwithcoordinates:self->ChuckCoordinate + 400 platform:[unSwappablePlatforms objectAtIndex:2] swapvalue:false]];
    }
    if(arc4random()%100<30)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+675 ycoord:160 swapvalue:false]];
    }
}
-(void) hard4
{
    int rand = (arc4random()%2);
    int rand2 = (arc4random()%2);
    int height;
    int height2;
    if(rand==0)
    {
        height = 230;
        height2 = 90;
    }
    else
    {
        height = 90;
        height2 = 230;
    }
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 60+(200*i) ycoord:height]];
    } 
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 600+(200*i) ycoord:height2]];
    } 
    if(arc4random()%2)
    {
        [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 200 y:height+70  nextx:self->ChuckCoordinate + 200 nexty:height-70 speed:4.1 big:rand2]];
    }
    else
    {
        [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 200 y:height-70  nextx:self->ChuckCoordinate + 200 nexty:height+70 speed:4.1 big:rand2]];
    }
    if(arc4random()%2)
    {
        [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 700 y:height2+70  nextx:self->ChuckCoordinate + 700 nexty:height2-70 speed:4.1 big:!rand2]];
    }
    else
    {
        [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 700 y:height2-70  nextx:self->ChuckCoordinate + 700 nexty:height2+70 speed:4.3 big:!rand2]];
    }
    if(arc4random()%100<30)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+300 ycoord:height-30 swapvalue:false]];
    }
}
-(void) hard5
{
    int rand = (arc4random() %2);
    int height;
    if(arc4random()%2)
    {
        height = 250;
    }
    else
    {
        height = 70;
    }
    for(int i = 0; i<1;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 60+(200*i) ycoord:160]];
    }
    for(int i = 0; i<2;i++)
    {
        [unSwappablePlatforms addObject:[[UnswappablePlatform alloc] initwithcoordinates: self->ChuckCoordinate + 260+(200*i) ycoord:160]];
    } 
    for(int i = 0; i<2;i++)
    {
        [platforms addObject:[[Platform alloc] initwithcoordinates: self->ChuckCoordinate + 660+(200*i) ycoord:160]];
    }
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 200 y:190  nextx:self->ChuckCoordinate + 560 nexty: 190 speed:(arc4random()%3)/5+1.7 big:rand]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 200 y:130  nextx:self->ChuckCoordinate + 560 nexty: 130 speed:(arc4random()%3)/5+1.7 big:!rand]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 600 y:190  nextx:self->ChuckCoordinate + 900 nexty: 190 speed:3.2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 600 y:130  nextx:self->ChuckCoordinate + 900 nexty: 130 speed:3.2 big:true]];
    [saws addObject:[[Saw alloc] initwithpoints:self->ChuckCoordinate + 600 y:height  nextx:self->ChuckCoordinate + 900 nexty: height speed:3.2 big:true]];
    if(arc4random()%100<25)
    {
        [stars addObject:[[Star alloc] initwithcoordinates:self->ChuckCoordinate+170 ycoord:140+(rand*40) swapvalue:false]];
    }
}
@end
