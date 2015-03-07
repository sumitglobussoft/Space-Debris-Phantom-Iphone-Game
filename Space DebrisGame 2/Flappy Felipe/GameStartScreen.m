//
//  GameStartScreen.m
//  Space Debris
//
//  Created by Globussoft 1 on 6/20/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "GameStartScreen.h"
#import "LevelSelectionScene.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppStore.h"
#import "GameStatus.h"

#import "ViewController.h"

#import "FMMParallaxNode.h"

#import "GAI.h"
#import  "GAIDictionaryBuilder.h"


//static NSString *const kFontName = @"PressStart2P";
#define kNumAsteroids   15

@interface GameStartScreen()
{
 
}
@end

@implementation GameStartScreen{
 FMMParallaxNode *_parallaxNodeBackgrounds;
}
@synthesize _musicPlayer;


-(id)initWithSize:(CGSize)size {
 if (self = [super initWithSize:size]) {
     SKSpriteNode  *background ;
     
     rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];

     [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];


   if([UIScreen mainScreen].bounds.size.height>500){
    background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg1.png"];
      }
      else{
          
    background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg.png"];
     }
     
     background.anchorPoint = CGPointMake(0.5, 1);
    background.position = CGPointMake(self.size.width/2, self.size.height);
    [self addChild:background];
          
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FacebookStatus) name:@"openSession" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkFacebookStatus) name:@"openSessionCancel" object:nil];
    
     
     NSArray *parallaxBackgroundNames = @[@"bg_galaxy.png", @"bg_planetsunrise.png",
                                          @"bg_spacialanomaly.png", @"bg_spacialanomaly2.png"];
     CGSize planetSizes = CGSizeMake(200.0, 200.0);
     
     _parallaxNodeBackgrounds = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames size:planetSizes
    pointsPerSecondSpeed:10.0];
     _parallaxNodeBackgrounds.position = CGPointMake(size.width/2.0, size.height/2.0);
     [_parallaxNodeBackgrounds randomizeNodesPositions];
     [self addChild:_parallaxNodeBackgrounds];
     
        
     BOOL networkConnection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable" ];
     if (networkConnection) {
//         [Chartboost showInterstitial:CBLocationStartup];
     }
     
     SKLabelNode *noteLabel=[[SKLabelNode alloc] initWithFontNamed:@"PressStart2P"];
     noteLabel.text=@"Note: Apple Inc. is not sponsor for contest ";
     noteLabel.position=CGPointMake(160, 18);
     noteLabel.zPosition=100;
     noteLabel.fontColor = [UIColor whiteColor];
     noteLabel.name=@"note";
     noteLabel.fontSize=7.0;
     noteLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
     [self addChild:noteLabel];
     
     self.lifeBuy=[[SKSpriteNode alloc] initWithImageNamed:@"store2.png"];
     self.lifeBuy.position=CGPointMake(250, 90);
     self.lifeBuy.name=@"store";
     self.lifeBuy.zPosition=40;
     [self addChild:self.lifeBuy];

     
     ready = [SKSpriteNode spriteNodeWithImageNamed:@"taptoplay1.png"];
     ready.position = CGPointMake(160,230);
     ready.name = @"Tutorial2";
     ready.zPosition = 40 ;
     [self addChild:ready];
     
     logo = [SKSpriteNode spriteNodeWithImageNamed:@"ready.png"];
     if([UIScreen mainScreen].bounds.size.height>500){
        logo.position = CGPointMake(170,420);
     }
     else{
        logo.position = CGPointMake(170,400);
     }
     logo.name = @"Tutorial3";
     logo.zPosition = 60 ;
     [self addChild:logo];

     
     //Falling star animation
     [self setupSpaceSceneLayers];
     
    //Moving Star animation
     [self addChild:[self loadEmitterNode:@"stars1"]];
     [self addChild:[self loadEmitterNode:@"stars2"]];
     [self addChild:[self loadEmitterNode:@"stars3"]];
     
     
     [[NSUserDefaults standardUserDefaults]setObject:@"runThroughStart" forKey:@"checkForRunning" ];
     [[NSUserDefaults standardUserDefaults]synchronize];
     
     BOOL check = [[NSUserDefaults standardUserDefaults] boolForKey:FacebookConnected];
     
     if (check==NO) {

     self.connectToFacebook = [[SKSpriteNode alloc] initWithImageNamed:@"connect_fb.png"];
         self.connectToFacebook.zPosition=30;
     self.connectToFacebook.position = CGPointMake(100, 90);
     self.connectToFacebook.name=@"connectToFacebook";
    [self addChild:self.connectToFacebook];
     }else{
     
         
         self.fbLogout = [[SKSpriteNode alloc] initWithImageNamed:@"logout.png"];
         self.fbLogout.zPosition=30;
         self.fbLogout.position = CGPointMake(100, 90);
         self.fbLogout.name=@"logoutFB";
         [self addChild:self.fbLogout];

         
         
//       self.lifeBuy.position=CGPointMake(160, 90);
     }
     
     
     self.showLeaderBoard = [[SKSpriteNode alloc] initWithImageNamed:@"join_contest.png"];
     self.showLeaderBoard.zPosition=30;
     self.showLeaderBoard.position = CGPointMake(self.frame.size.width/2, 45);
     self.showLeaderBoard.name=@"ShowLeaderBoard";
     [self addChild:self.showLeaderBoard];
     
         //Astroid moving animation
     _asteroids = [[NSMutableArray alloc] initWithCapacity:kNumAsteroids];
     for (int i = 0; i < kNumAsteroids; ++i) {
         SKSpriteNode *asteroid = [SKSpriteNode spriteNodeWithImageNamed:@"element1.png"];
         asteroid.hidden = YES;
         asteroid.zPosition=1;
         [asteroid setXScale:0.5];
         [asteroid setYScale:0.5];
         [_asteroids addObject:asteroid];
         [self addChild:asteroid];
     }
     
     
     _asteroids1 = [[NSMutableArray alloc] initWithCapacity:kNumAsteroids];
     for (int i = 0; i < kNumAsteroids; ++i) {
         SKSpriteNode *asteroid1 = [SKSpriteNode spriteNodeWithImageNamed:@"element2.png"];
         asteroid1.hidden = YES;
         asteroid1.zPosition=1;
         [asteroid1 setXScale:0.5];
         [asteroid1 setYScale:0.5];
         [_asteroids1 addObject:asteroid1];
         [self addChild:asteroid1];
     }

     
  [self playMusic];
     
   }

    return  self;
}


-(void)FacebookStatus{
    self.connectToFacebook.hidden=YES;
    self.fbLogout = [[SKSpriteNode alloc] initWithImageNamed:@"logout.png"];
    self.fbLogout.zPosition=30;
    self.fbLogout.position = CGPointMake(100, 90);
    self.fbLogout.name=@"logoutFB";
    [self addChild:self.fbLogout];
    self.connectToFacebook.hidden=YES;


}
-(void)checkFacebookStatus{
       if(!self.connectToFacebook){
        
           [[AppDelegate sharedAppDelegate]showToastMessage:@"Facebook session Logout"];

        self.connectToFacebook = [[SKSpriteNode alloc] initWithImageNamed:@"connect_fb.png"];
        self.connectToFacebook.zPosition=30;
        self.connectToFacebook.position = CGPointMake(100, 90);
        self.connectToFacebook.name=@"connectToFacebook";
        [self addChild:self.connectToFacebook];

    
       }else{
         self.connectToFacebook.hidden=NO;
           [[AppDelegate sharedAppDelegate]showToastMessage:@"Facebook session Cancel"];

       }
   
    
}


-(void)update:(CFTimeInterval)currentTime {

    [_parallaxNodeBackgrounds update:currentTime];
    
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        
        float randSecs=[self randomValueBetween:2.0  andValue:5.0];
        _nextAsteroidSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:self.frame.size.height];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
        SKSpriteNode *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
         _nextAsteroid++;
        
        if (_nextAsteroid >= _asteroids.count) {
            _nextAsteroid = 0;
        }
        
           [asteroid removeAllActions];
        asteroid.position = CGPointMake(self.frame.size.width+asteroid.size.width/2, randY);
    
        asteroid.hidden = NO;
        
        CGPoint location = CGPointMake(-self.frame.size.width-asteroid.size.width, randY);
     
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
            asteroid.hidden = YES;
        }];
                
        SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
        
        [asteroid runAction:moveAsteroidActionWithDone withKey:@"asteroidMoving"];
        }
}



- (float)randomValueBetween:(float)low andValue:(float)high {
        
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

    
    
- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
        //do some view specific tweaks
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
    
    return emitterNode;
    
}

- (void)playMusic
{
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"SpaceGame"
                                         ofType:@"mp3"]];
     NSError *error;
    _musicPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:url
                    error:&error];
    _musicPlayer.numberOfLoops=-1;
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        _musicPlayer.delegate = self;

     [_musicPlayer play];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
   if ( [node.name isEqualToString:@"Tutorial2"]) {
       if (_musicPlayer) {
           [_musicPlayer stop];
           _musicPlayer=nil;
           
       }
       [[NSNotificationCenter defaultCenter] postNotificationName:@"adMobBanner" object:nil];

   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openSession" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openSessionCancel" object:nil];
    [self removeActionForKey:@"ToPlay"];
   SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
     LevelSelectionScene *newScene = [[LevelSelectionScene alloc] initWithSize:self.size ];
     [tutorial removeFromParent];
     [ready removeFromParent];
     [logo removeFromParent];
       tutorial=nil;
       ready=nil;
       logo=nil;
       self.lifeBuy=nil;
       self.fbLogout=nil;
       self.connectToFacebook=nil;
       _asteroids=nil;
       _asteroids1=nil;
       [self removeAllActions];
       [self.scene.view presentScene: newScene transition: reveal];
 }
    if ( [node.name isEqualToString:@"connectToFacebook"]){
        
    BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
  
        if (netWorkConnection==YES) {
            
//        if (!(FBSession.activeSession.isOpen)) {
            if (_musicPlayer) {
                [_musicPlayer stop];
                _musicPlayer=nil;
                
            }
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            NSLog(@"Tracker %@",tracker);
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ConnectWithFB"     // Event category (required)
                                                                  action:@"FB_button"  // Event action (required)
                                                                   label:@"FB_Connect"          // Event label
                                                                   value:nil] build]];    // Event value
            

            
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         [appDelegate openSessionWithLoginUI:8 withParams:nil isLife:@"No"];
           
//                [self.connectToFacebook removeFromParent];
//                self.connectToFacebook=nil;
//            if (loginSuccess) {
//                self.connectToFacebook.hidden=YES;
//                self.fbLogout = [[SKSpriteNode alloc] initWithImageNamed:@"logout.png"];
//                self.fbLogout.zPosition=30;
//                self.fbLogout.position = CGPointMake(100, 90);
//                self.fbLogout.name=@"logoutFB";
//                [self addChild:self.fbLogout];
//                self.connectToFacebook.hidden=YES;
//            }
            
           

            
//              self.connectToFacebook.hidden=YES;
//         self.lifeBuy.position=CGPointMake(160, 90);
            [self playMusic];
      
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Internet not connected" message:@"Check Your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    if ( [node.name isEqualToString:@"store"]){
        
        if (_musicPlayer) {
            [_musicPlayer stop];
            _musicPlayer=nil;
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"adMobBanner" object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openSession" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openSessionCancel" object:nil];
        AppStore *appstore=[[AppStore alloc] initWithSize:self.size];
        [self.scene.view presentScene:appstore];
        [tutorial removeFromParent];
        [ready removeFromParent];
        [logo removeFromParent];
        tutorial=nil;
        ready=nil;
        logo=nil;
        self.lifeBuy=nil;
        self.fbLogout=nil;
        self.connectToFacebook=nil;
        _asteroids=nil;
        _asteroids1=nil;
        [self removeAllActions];
    }
    
    if ( [node.name isEqualToString:@"logoutFB"]){
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FacebookConnected];

        [[NSUserDefaults standardUserDefaults]synchronize];
        self.fbLogout.hidden=YES;

        if (FBSession.activeSession.isOpen) {
       
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
        }else{
            
            self.connectToFacebook = [[SKSpriteNode alloc] initWithImageNamed:@"connect_fb.png"];
            self.connectToFacebook.zPosition=30;
            self.connectToFacebook.position = CGPointMake(100, 90);
            self.connectToFacebook.name=@"connectToFacebook";
            [self addChild:self.connectToFacebook];
            
        }
        
    }
    if ( [node.name isEqualToString:@"ShowLeaderBoard"]|| ((self.showLeaderBoard.position.x==location.x)&&(self.showLeaderBoard.position.y==location.y))){
        
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.globusgames.com/space-debris-phantom-leader-board-ios/"]];
    }

}



-(void) storyPostUpdate{
    
    NSString *title = [NSString stringWithFormat:@"New highscore 100!"];
    
    NSString *description = [NSString stringWithFormat:@"Hey i got new highscore 100 in level 1"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"highscore",FacebookType,title,FacebookTitle,description,FacebookDescription,@"get",FacebookActionType, nil];
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (FBSession.activeSession.isOpen) {
        
        [appDelegate shareOnFacebookWithParams:dict islife:@"No"];
    }
    else{
        
        [appDelegate openSessionWithLoginUI:3 withParams:dict isLife:@"No"];
        
    }
}


-(void)askFrndsButtonClicked:(id)sender {
    NSLog(@"Ask Friends Button Click");
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    BOOL check = [[NSUserDefaults standardUserDefaults] boolForKey:FacebookConnected];
    
    if (check == NO) {
        [appDelegate openSessionWithLoginUI:8 withParams:nil isLife:@"No"];
//        appDelegate.delegate = self;
    }
    else{
        [self displayFbFrnds];
    }
}
-(void) displayFacebookFriendsList{
    [self displayFbFrnds];
}
-(void) displayFbFrnds{
    
//    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    ViewController *viewCntrler = (ViewController*)[appDelegate getRootViewController];
    CGRect frame = [UIScreen mainScreen].bounds;
    FriendsViewController *fbFrnds = [[FriendsViewController alloc] initWithHeaderTitle:@"Ask for Life"];//WithNibName:@"FriendsViewController" bundle:nil];
    fbFrnds.view.frame = CGRectMake(0, 0, frame.size.width, 0);;
        //fbFrnds.headerTitle = @"Ask Life";
    [UIView animateWithDuration:1 animations:^{
        
        fbFrnds.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [rootViewController presentViewController:fbFrnds animated:YES completion:nil];
        //[viewCntrler.view addSubview:fbFrnds.view];
    }];
}
- (void)setupSpaceSceneLayers {
    
    
    NSString *largeStar = @"star2.png";
    NSString *smallStar = @"star3.png";
    
    SKEmitterNode *layer2 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.2 lifetime:(self.frame.size.height/5) speed:-10 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer2.zPosition=10;
    
    SKEmitterNode *layer3 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.6 lifetime:(self.frame.size.height/8) speed:-12 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:YES];
    layer3.zPosition=15;
    
    [self addChild:layer2];
    [self addChild:layer3];

    
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

#pragma mark -
#pragma mark - RevMobAppDelegate


@end
