//
//  ButtonSlide.m
//  MyPlatformer
//
//  Created by Nikhil Khanna on 7/25/12.
//  Copyright (c) 2012 Tangled Fire. All rights reserved.
//

#import "ButtonSlide.h"
#import "SimpleAudioEngine.h"
@implementation ButtonSlide
int leveltoplay = 0; 
CCMenu* menu;
CCLabelTTF* notEnough;
-(id) initwithbuttons: (int) firstbutton size: (int) numbuttons
{
    if((self = [super initWithFile:@"ButtonSlide.png"]))
    {
        self.position = ccp(240, 160);
        NSMutableArray* buttons = [[NSMutableArray alloc] init];
        NSMutableArray* chains = [[NSMutableArray alloc]init];
        for (int i = firstbutton; i<numbuttons+firstbutton; i++)//iterating through the buttons in accordance with the params 
        {
            bool locked;
            if(i==1||[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"Level%d",i-1]]>-1)//if is first level or other levels are completed
            {
                if((i==16&&[self numtotalStars]<30)||(i==31&&[self numtotalStars]<60))//if stars are the limiting factor
                {
                    locked = true;
                    int starsrequired;
                    int totalStars = [self numtotalStars];
                    if(i==16)
                    {
                        starsrequired = 30-totalStars;
                    }
                    else
                    {
                        starsrequired = 60-totalStars;
                    }
                    NSString* myString;
                    if(starsrequired ==1)
                        myString = [NSString stringWithFormat:@"You need %d more star to progress", starsrequired];
                    else
                        myString = [NSString stringWithFormat:@"You need %d more stars to progress", starsrequired];
                    notEnough = [CCLabelTTF labelWithString:myString fontName:@"Arial" fontSize:20];
                    notEnough.position=ccp(175, 250);
                    [self addChild:notEnough z:2];
                }
                else
                {
                    locked = false;//not locked
                }
            }
            else
            {
                locked = true;
            }
            NSMutableString* level = [NSMutableString stringWithFormat:@"Level_%d.png",i];
            NSMutableString* Selectedlevel = [NSMutableString stringWithFormat:@"Level_touch_%d.png",i];
            CCMenuItem* thislevel;
            if(!locked)
            {
                thislevel = [CCMenuItemImage itemFromNormalImage:level selectedImage:Selectedlevel target:self selector:@selector(changeLevelNum:)];
            }
            else
            {
                thislevel = [CCMenuItemImage itemFromNormalImage:level selectedImage:level];//button w/ no effect and no result from being pressed
            }
            int myStarNum;
            int myNumber=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"Level%d",i]];
            if(myNumber<1)
            {
                myStarNum = 0;
            }
            else
            {
                myStarNum = myNumber;
            }
            CCMenuItem* starHolder = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"Star_Holder_%d.png",myStarNum] selectedImage:[NSString stringWithFormat:@"Star_Holder_%d.png",myStarNum]];
            [thislevel setScale:2];
            [starHolder setScale:.75];
            if(firstbutton==1)
            {
                thislevel.position = ccp(-210+((i-1)%5)*70,(10-(int)((i-1)/5)*70)+20);
                starHolder.position = ccp(-210+((i-1)%5)*70,(10-(int)((i-1)/5)*70)-5);
            }
            else if(firstbutton==16)
            {
                thislevel.position = ccp(-210+((i-1)%5)*70,(220-(int)((i-1)/5)*70)+20);
                starHolder.position = ccp(-210+((i-1)%5)*70,(220-(int)((i-1)/5)*70)-5);
            }
            else if (firstbutton==31)
            {
                thislevel.position = ccp(-210+((i-1)%5)*70,(430-(int)((i-1)/5)*70)+20);
               starHolder.position = ccp(-210+((i-1)%5)*70,(430-(int)((i-1)/5)*70)-5);
            }
            thislevel.tag = i;
            if(locked)
            {
                CCMenuItemImage* chain = [CCMenuItemImage itemFromNormalImage:@"Level_chain.png" selectedImage:@"Level_chain.png"];
                [chain setScale:2];
                chain.position = thislevel.position;
                [chains addObject:chain];
            }
            [buttons addObject:thislevel];
            [buttons addObject:starHolder];
        }
        menu = [CCMenu menuWithItems: nil];
        for (int i = 0; i<numbuttons*2; i++) 
        {
            [menu addChild:[buttons objectAtIndex:i]];
        }
        for (int i = 0; i<chains.count; i++) 
        {
            [menu addChild:[chains objectAtIndex:i]];
        }
        [self addChild:menu];
    }
    return self;
}
-(void) changeLevelNum: (CCMenuItem*) levelnum
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
    leveltoplay = levelnum.tag;
}
-(int) currentLevelNumber
{
    return leveltoplay;
}
-(void)dealloc
{
    [self removeAllChildrenWithCleanup:true];
    leveltoplay = 0;
    [super dealloc];
}
-(CGPoint) getPosition
{
    return self.position;
}
-(int) numtotalStars
{
    int totalStarsCounter = 0;
    for(int i = 1; i<46;i++)
    {
        int levelStars = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"Level%d",i]];
        if(levelStars>0)
        {
            totalStarsCounter+=levelStars;//adding the stars on a sepcific level to the counter
        }
    }
    return totalStarsCounter;
}
-(void) setPosition: (int) x ycoordinate: (int) y
{
    self.position = ccp(x, y);
}
@end
