//
//  Platform.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 6/28/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "Platform.h"
#import "Player.h"
@implementation Platform
-(id) initwithcoordinates: (int) x ycoord: (int) y
{
    if((self = [super initWithSpriteFrameName:@"NewWoodPlatform.png"]))
    {
        self.position = ccp(x, y);
    }
    return self;
}
-(CGFloat) width
{
    return [self boundingBox].size.width;
}
-(CGFloat) height
{
    return [self boundingBox].size.height;
}
-(CGFloat) halfwidth
{
    return [self width]/2;
}
-(CGFloat) halfheight
{
    return [self height]/2;
}
-(void) setX: (CGFloat) x
{
    self.position = ccp(x, self.position.y);
}
-(CGFloat) giveHeight: (SwappableCCSprite*) sprite
{
    if([sprite isSwapped])
    {
        return position_.y-([sprite height]/2);//origin is center of sprite
    }
    return position_.y+([sprite height]/2);//same
}
-(bool) stopSprite: (Player*) player//stops the player
{
    if([player isOn:self])
    {
        if(([player getJumping]&&[player getFalling])||![player getJumping])
        {
           // [player playerStopJump];
            player.position = ccp(player.position.x, [self giveHeight:player]);
            return true;
        }
    }
    return false;
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
-(void) updateCameraPosition: (int) correctionFactor
{
    self.position = ccp(self.position.x+correctionFactor, self.position.y);
}
-(bool) isOffScreen
{
    if(position_.x<0-[self width])
    {
        return true;
    }
    return false;
}
-(void) VisiblityUpdate
{
    if(self.position.x<0-[self halfwidth]||self.position.x>480+[self halfwidth])
    {
        self.visible = NO;
    }
    else 
    {
        self.visible = YES;
    }
}
@end
