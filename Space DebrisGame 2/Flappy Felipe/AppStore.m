//
//  AppStore.m
//  Space Debris
//
//  Created by Globussoft 1 on 7/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "AppStore.h"
#import "GameStartScreen.h"
#import "RageIAPHelper.h"
#import "GAI.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"

@implementation AppStore
static NSString *const kFontName = @"PressStart2P";
static NSString *const kFontName1 = @"NKOTB Fever";
-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background;
        if([UIScreen mainScreen].bounds.size.height>500){
            background  = [[SKSpriteNode alloc]initWithImageNamed:@"blankbg1.png"];
        }
        else{
            
            background  = [[SKSpriteNode alloc]initWithImageNamed:@"blankbg.png"];
        }
        background.anchorPoint = CGPointMake(0.5, 1);
        background.position = CGPointMake(self.size.width/2, self.size.height);
            //        background.zPosition = LayerBackground;
        [self addChild:background];
        
        
        self.backButton=[[SKSpriteNode alloc]initWithImageNamed:@"back.png"];
        self.backButton.position=CGPointMake(50, self.size.height-30);
        self.backButton.name=@"Back";
        self.backButton.zPosition=70;
        [self addChild:self.backButton];
        
        SKSpriteNode *storeLabel=[[SKSpriteNode alloc] initWithImageNamed:@"storescreen.png"];
        if([UIScreen mainScreen].bounds.size.height>500){
          storeLabel.position=CGPointMake(160, 420);
        }else{
          storeLabel.position=CGPointMake(160, 390);
        }
      
        storeLabel.zPosition=40;
        [self addChild:storeLabel];
        
        [self setupSpaceSceneLayers];
        
        
        SKSpriteNode *lifeLabel=[[SKSpriteNode alloc] initWithImageNamed:@"5life.png"];
        lifeLabel.position=CGPointMake(110, 220);
        [self addChild:lifeLabel];
        lifeLabel.zPosition=40;
        
//  self.interstitial = [self createAndLoadInterstitial];
        
        SKSpriteNode *lifeBuy=[[SKSpriteNode alloc] initWithImageNamed:@"buy.png"];
        lifeBuy.position=CGPointMake(265, 240);
        lifeBuy.name=@"lifeBuy";
        lifeBuy.zPosition=40;
        [self addChild:lifeBuy];
        
// [self addExplosion:CGPointMake(50, 400) withName:@"LifeBarExplosion"];
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
      
    }
    return  self;
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            NSLog(@"Products List -==- %@",_products);
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
        if ( [node.name isEqualToString:@"lifeBuy"]) {
        
                  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        NSLog(@"Tracker %@",tracker);
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Life_Purchase"     // Event category (required)
                                                              action:@"Buy_Button"  // Event action (required)
                                                               label:@"Buy"          // Event label
                                                               value:nil] build]];    // Event value
        

        BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
        if (connection==YES) {
            [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];

        [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
            NSLog(@"Products -==--= %@",products);
            if (success) {
                
                if (products.count <=0) {
                    
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"Please check your internet connection and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                }
                else{
                    
                    SKProduct *product = products[0];
                    
                    NSLog(@"Buying %@...", product.productIdentifier);
                    [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];

                [[RageIAPHelper sharedInstance] buyProduct:product];
                }
            }
        }];
            
        }else{
        
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Please Check Internet" message:@"No Internet Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([node.name isEqualToString:@"Back"]) {
        
       GameStartScreen *gameStartScreen=[[GameStartScreen alloc] initWithSize:self.size];
        [self.scene.view presentScene:gameStartScreen];
        
            //        }
    }
}


- (void)setupSpaceSceneLayers {
    
        //    _layerBackgroundNode = [SKNode new];
        //    _layerBackgroundNode.name = @"spaceBackgroundNode";
    
        //The last layer added will be on top...add the smallest (furthest away) stars first
    
    NSString *largeStar = @"star2.png";
    NSString *smallStar = @"star3.png";
    
        //small star layer 1--furthest away
        //    SKEmitterNode *layer1 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/5) speed:-8 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:NO];
        //    layer1.zPosition=5;
    
    SKEmitterNode *layer2 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.2 lifetime:(self.frame.size.height/5) speed:-10 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer2.zPosition=10;
    
    SKEmitterNode *layer3 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.6 lifetime:(self.frame.size.height/8) speed:-12 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:YES];
    layer3.zPosition=15;
    
        //small star layer 4--closest
    SKEmitterNode *layer4 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/10) speed:-14 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer4.zPosition=20;
    
        //    [self addChild:layer1];
    [self addChild:layer2];
    [self addChild:layer3];
    [self addChild:layer4];
    
}


- (SKEmitterNode *)spaceStarEmitterNodeWithBirthRate:(float)birthRate
                                               scale:(float)scale
                                            lifetime:(float)lifetime
                                               speed:(float)speed
                                               color:(SKColor *)color
                                         textureName:(NSString *)textureName
                                     enableStarLight:(BOOL)enableStarLight
{
    SKTexture *starTexture = [SKTexture textureWithImageNamed:textureName];
    starTexture.filteringMode = SKTextureFilteringNearest;
    
    SKEmitterNode *emitterNode = [SKEmitterNode new];
    emitterNode.particleTexture = starTexture;
    emitterNode.particleBirthRate = birthRate;
    emitterNode.particleScale = scale;
    emitterNode.particleLifetime = lifetime;
    emitterNode.particleSpeed = speed;
    emitterNode.particleSpeedRange = 10;
    emitterNode.particleColor = color;
    
    emitterNode.particleColorBlendFactor = 1;
    emitterNode.position = CGPointMake((CGRectGetMidX(self.frame)), CGRectGetMaxY(self.frame));
    
    emitterNode.particlePositionRange = CGVectorMake(CGRectGetMaxX(self.frame), 0);
    [emitterNode advanceSimulationTime:lifetime];
    
        //setup star light
    if(enableStarLight) {
        float lightFluctuations = 15;
        SKKeyframeSequence * lightSequence = [[SKKeyframeSequence alloc] initWithCapacity:lightFluctuations *2];
        
        float lightTime = 1.0/lightFluctuations;
        for (int i = 0; i < lightFluctuations; i++) {
            [lightSequence addKeyframeValue:[SKColor whiteColor] time:((i * 2) * lightTime / 2)];
            [lightSequence addKeyframeValue:[SKColor yellowColor] time:((i * 2 + 2) * lightTime / 2)];
        }
        
        emitterNode.particleColorSequence = lightSequence;
    }
    
    return emitterNode;
}

-(void)addExplosion:(CGPoint)position withName:(NSString*)name
{
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    explosion.position = position;
    [self addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
    
}


@end
