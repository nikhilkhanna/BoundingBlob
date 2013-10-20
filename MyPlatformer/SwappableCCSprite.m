//
//  SwappableCCSprite.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/24/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//
#import "cocos2d.h"
#import "SwappableCCSprite.h"
#import "Platform.h"
@implementation SwappableCCSprite
-(bool) SwappableCollision: (SwappableCCSprite*) s
{
    if(Swapped==s->Swapped)
    {
        if(CGRectIntersectsRect(self.textureRect, s.textureRect))
        {   
            return true;
        }
    }
    return false;
}
-(id) init
{
    if( (self=[super init])) 
    {
        Swapped = false;
    }
    return self;
}
-(id) fileInit:(NSString*) name swapvalue: (bool) myswapvalue
{
    if((self = [super initWithFile:name]))
    {
        Swapped = myswapvalue;
        if(Swapped)
        {
            CCFlipY* flipy = [CCFlipY actionWithFlipY:YES];
            self.position = ccp(position_.x, position_.y-[self height]);
            [self runAction:flipy];
        }
    }
    return self;
}
-(id) fileInitWithFrame:(NSString*) name swapvalue: (bool) myswapvalue
{
    if((self = [super initWithSpriteFrameName:name]))
    {
        Swapped = myswapvalue;
        if(Swapped)
        {
            CCFlipY* flipy = [CCFlipY actionWithFlipY:YES];
            self.position = ccp(position_.x, position_.y-[self height]);
            [self runAction:flipy];
        }
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
- (void) dealloc
{	
	// don't forget to call "super dealloc"
    [self setVisible:false];
	[super dealloc];
}
-(void) Update
{
    self.position=ccp(position_.x-3, position_.y);
    [self VisiblityUpdate];
}
-(void) EndlessUpdate
{
    [self VisiblityUpdate];
}
-(bool) isOffScreen
{
    if(position_.x<=0-[self halfwidth])
    {
        return true;
    }
    return false;
}
-(bool) isOffScreenRight
{
    if(position_.x>=480+[self width]/2)
    {
        return true;
    }
    return false;
}
-(bool)isInView
{
    if(position_.x<=480+[self width]/2&&position_.x>0-[self halfwidth])
    {
        return true;
    }
    return false;
}
-(bool) Intersects:(SwappableCCSprite *)sprite
{
    if(Swapped == sprite->Swapped)
    {
        if(CGRectIntersectsRect([self newboundingBox], [sprite newboundingBox]))
        {
            return true;
        }
    }
    return false;
}
-(bool) IntersectsIgnoreSwap:(CCSprite*)sprite
{
    if(CGRectIntersectsRect([self newboundingBox], [sprite boundingBox]))
       {
           return true;
       }
       return false;
}
-(bool) IntersectsIgnoreSwapSwappableSprite:(SwappableCCSprite*)sprite
{
    if(CGRectIntersectsRect([self newboundingBox], [sprite newboundingBox]))
    {
        return true;
    }
    return false;
}
-(bool) isSwapped
{
    return Swapped;
}
-(bool) isOn:(Platform *)platform//note we assume platform is FLAT
{
    if([self isAlignedX:platform])
    {
        if(Swapped)
        {
            if(position_.y+[self halfheight]-platform.position.y>-10&&position_.y+[self halfheight]-platform.position.y<10)
            {
                return true;
            }
        }
        if(!Swapped)
        {
            if(position_.y-[self halfheight]-platform.position.y<10&&position_.y-[self halfheight]-platform.position.y>-10)
            {
                return true;
            }
        }
    }
    return false;
}
-(bool) isAlignedX:(Platform*)platform//if is aligned on the x axis
{
    if(position_.x+[self halfwidth]>platform.position.x-[platform halfwidth]&&position_.x-[self halfwidth]<platform.position.x+[platform halfwidth])//if it is lined up
    {
        return true;
    }
   return false;
}
-(void) updateCameraPosition: (int) correctionFactor
{
    self.position = ccp(self.position.x+correctionFactor, self.position.y);
}
-(CGRect) newboundingBox//default no change
{
    return [self boundingBox];
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
-(void) setX: (CGFloat) x
{
    self.position = ccp(x, self.position.y);
}
@end
