//
//  GameResume.m
//  Space Debris
//
//  Created by Globussoft 1 on 7/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "GameResume.h"

@implementation GameResume
-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
    
    
        SKSpriteNode *background =[[SKSpriteNode alloc] initWithImageNamed:@"blankbg.png"];
        background.anchorPoint = CGPointMake(0.5, 1);
        background.position = CGPointMake(self.size.width/2, self.size.height);
            //        background.zPosition = LayerBackground;
        [self addChild:background];
        
        
//        SKLabelNode *menuButton=[[SKLabelNode alloc] initWithFontNamed:kFontName1];
//        menuButton.text=@"Buy 5 life";
//        
//        menuButton.position=CGPointMake(10, 150);
//        [self addChild:menuButton];
        
        
        
        SKSpriteNode *resumeButton=[[SKSpriteNode alloc] initWithImageNamed:@"buy.png"];
        resumeButton.position=CGPointMake(200, 150);
        resumeButton.name=@"resume";
        [self addChild:resumeButton];
        

    
    }
        return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ( [node.name isEqualToString:@"resume"]) {
        
//        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
//        A *newScene = [[LevelSelectionScene alloc] initWithSize:CGSizeMake(320, 480) ];
//  [self.scene.view presentScene: newScene transition: reveal];
        
//        self.scene.view=nil;
        
    }
    
    
}

@end
