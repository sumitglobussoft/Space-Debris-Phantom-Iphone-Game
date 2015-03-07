//
//  AppStore.h
//  Space Debris
//
//  Created by Globussoft 1 on 7/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface AppStore : SKScene {
    
     NSArray *_products;
}

-(id)initWithSize:(CGSize)size;
@property(nonatomic,strong) SKSpriteNode *backButton;

@end
