//
//  MyScene.m
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import "MyScene.h"
#import "LevelSelectionScene.h"
#import "GameOverScene.h"
#import "AppDelegate.h"
#import "GameStartScreen.h"
#import "AppStore.h"
#import "GameStatus.h"
#import "FMMParallaxNode.h"
#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>

#define kNumAsteroids   15

typedef NS_ENUM(int, Layer) {
  LayerBackground,
  LayerObstacle,
  LayerForeground,
  LayerPlayer,
  LayerUI
};

typedef NS_OPTIONS(int, EntityCategory) {
  EntityCategoryPlayer = 1 << 0,
  EntityCategoryObstacle = 1 << 1,
  EntityCategoryGround = 1 << 2 ,
  EntityCategoryAstroid= 1 << 3,
  EntityCategoryCoin= 1 << 4,
  EntityCategoryCoinMinus= 1 << 5,
  EntityCategoryImunePower =1<<6,
};

// Gameplay - astronaut movement
static  float kGravity = -1500.0;
static const float kImpulse = 400.0;

// Gameplay - ground speed
static  float kGroundSpeed = 150.0f;

// Gameplay - obstacles positioning
static const float kGapMultiplier = 2.0;
static const float kBottomObstacleMinFraction = 0.1;
static const float kBottomObstacleMaxFraction = 0.6;

// Gameplay - obstacles timing
//static const float kFirstSpawnDelay = 1.75;
//static const float kEverySpawnDelay = 1.5;

// Looks
static const int kNumForegrounds = 2;
static const float kMargin = 20;
//static const float kAnimDelay = 0.3;
//static NSString *const kFontName = @"PressStart2P";
//static NSString *const kFontName1 = @"NKOTB Fever";
static NSString *const kFontName1 = @"Party LET";
@interface MyScene() <SKPhysicsContactDelegate>
@end

@implementation MyScene {

  SKNode *_worldNode;
  
  float _playableStart;
  float _playableHeight;

  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
   
    FMMParallaxNode *_parallaxNodeBackgrounds;
    
  SKSpriteNode *_player;
  SKSpriteNode *_sombrero;

  CGPoint _playerVelocity;
  
  SKAction * _dingAction;
  SKAction * _flapAction;
  SKAction * _powerAction;
  SKAction * _whackAction;
  SKAction * _fallingAction;
  SKAction * _hitGroundAction;
  SKAction * _popAction;
  SKAction * _coinAction;
  
  BOOL _hitGround;
  BOOL _hitObstacle;
//    SKSpriteNode *coin;
  GameState _gameState;
  
    
    NSMutableArray *_asteroids;
    int _nextAsteroid;
    double _nextAsteroidSpawn;

    NSMutableArray *_coins;
    int _nextCoin;
    double _nextCoinSpawn;
    
    NSMutableArray *coinMinus;
    int _nextCoinMinus;
    double _nextCoinMinusSpawn;
  
//    SKLabelNode *lifeLabel;
    
    SKLabelNode *_scoreLabel;
    SKAction *firstDelay;
    SKAction *spawn;
     SKAction *everyDelay;
  int _score;
    int val;
}

@synthesize _musicPlayer;

-(id)initWithSize:(CGSize)size  {
  if (self = [super initWithSize:size]) {
      [GameStatus sharedState].isGamePlaying=YES;

      rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];
      
       [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lifeAdded) name:@"LifeAdded" object:nil];
      
      _isImmunePowerOn=NO;
      
      _score=(int)[GameStatus sharedState].remScore;
      isChartBoostLoadSuccess=NO;
      isInterstitialFail=YES;
      BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
      if (connection) {
//
//         Live
//          [Chartboost startWithAppId:@"54855fbe04b01619967e2159"
//                appSignature:@"6aea83bfc107bd7f6135bdf58b4165e218aaea0a"      delegate:self];
          
//          testing
          [Chartboost startWithAppId:@"54ef306204b01656bb289a4c"
              appSignature:@"47e70e91d2d86e1acb374add7cba77b532d18ad1"      delegate:self];
          
      }
      
      timerStop=0;
    [GameStatus sharedState].remLife  = [[NSUserDefaults standardUserDefaults]  integerForKey:@"life"];

    
    _worldNode = [SKNode node];
    [self addChild:_worldNode];
      
      isInterstitialFail=YES;

      [GameStatus sharedState].remLife=
      [[NSUserDefaults standardUserDefaults] integerForKey:@"life"];
      
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    [self switchToTutorial];
      
      self.gameOverDecision=YES;
      self.state=YES;
      
      self.time = [[SKLabelNode alloc] initWithFontNamed:kFontName];
      self.time.fontColor = [UIColor whiteColor];
      self.time.fontSize=20.0;
      
      if ([UIScreen mainScreen].bounds.size.height>500) {
          
        self.time.position = CGPointMake(150, 500);
      }
      else{
          
        self.time.position = CGPointMake(150, 420);
          
        }
      
    
      self.time.name=@"time";
      self.time.zPosition=20;
      self.time.verticalAlignmentMode =SKLabelVerticalAlignmentModeTop;
      [self addChild:self.time];
      
      self.Level = [[SKLabelNode alloc] init];
      self.Level.fontColor = [UIColor whiteColor];
      self.Level.fontSize=30.0;
      self.Level.fontName=@"Transformers Movie";
      if ([UIScreen mainScreen].bounds.size.height>500) {
          
            self.Level.position = CGPointMake(60, 540);
      }
      else{
            self.Level.position = CGPointMake(60, 460);
      }
     self.Level.text =[NSString stringWithFormat:@"Level %ld",(long)[GameStatus sharedState].levelNumber];

      self.Level.name=@"level";
      self.Level.zPosition=20;
      self.Level.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
      [self addChild:self.Level];


       self.num=1;
      [self playMusic];
      
      self.texure1 = [SKTexture textureWithImageNamed:@"music.png"];
     self.texure2 = [SKTexture textureWithImageNamed:@"Musicoff.png"];

      self.musicButton=[SKSpriteNode spriteNodeWithTexture:self.texure1];
      if ([UIScreen mainScreen].bounds.size.height>500) {
          
          self.musicButton.position = CGPointMake(25, self.size.height-460);      }
      else{
          self.musicButton.position = CGPointMake(25, self.size.height-380);
      }
        self.musicButton.name=@"music";
      self.musicButton.zPosition=5;
//      self.musicButton.userInteractionEnabled = YES;
      [self addChild:self.musicButton];
      
      NSArray *parallaxBackgroundNames;
      
      if ([GameStatus sharedState].levelNumber<=10) {
          
          
          parallaxBackgroundNames = @[@"bg_galaxy.png", @"bg_planetsunrise.png",
                                      @"bg_spacialanomaly.png", @"bg_spacialanomaly2.png"];
          
         
      }else if([GameStatus sharedState].levelNumber>10&&[GameStatus sharedState].levelNumber<=30){
          
          parallaxBackgroundNames = @[@"globe_1.png",@"bg_spacialanomaly_blue.png",@"bg_planetsunrise.png", @"bg_spacialanomaly2.png"];

         
      }else{
          parallaxBackgroundNames = @[@"bg_planetsunrise.png",
                                      @"bg_spacialanomaly_blue.png", @"bg_spacialanomaly2.png"];
      
      }
     
      CGSize planetSizes = CGSizeMake(200.0, 200.0);
      
      _parallaxNodeBackgrounds = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackgroundNames
                                                                         size:planetSizes
                                                         pointsPerSecondSpeed:10.0];
      _parallaxNodeBackgrounds.position = CGPointMake(size.width/2.0, size.height/2.0);
      [_parallaxNodeBackgrounds randomizeNodesPositions];
      _parallaxNodeBackgrounds.userInteractionEnabled=NO;
      [self addChild:_parallaxNodeBackgrounds];
      
      
      self.timeMin = 00;
      self.timeSec = 30;
      self.timeSec=(int)[GameStatus sharedState].remTime;
      if (self.timeSec==0) {
           self.timeSec = 30;
      }
          
      
          //Format the string 00:00
      NSString* timeNow = [NSString stringWithFormat:@"            %02d:%02d", self.timeMin, self.timeSec];
      self.time.text=timeNow;
       
      
      self.pauseButton=[[SKSpriteNode alloc] initWithImageNamed:@"pause.png"];
      
      if ([UIScreen mainScreen].bounds.size.height>500) {
          
          self.pauseButton.position = CGPointMake(25, 50);    
      }
      else{
          self.pauseButton.position = CGPointMake(25, 50);
      }
//         self.pauseButton.userInteractionEnabled = YES;
      self.pauseButton.name=@"pause";
      self.pauseButton.zPosition=10;
      [self addChild:self.pauseButton];
      
      
      self.pauseOrResume=1;
      #pragma mark - Setup the +10coins
      _coins = [[NSMutableArray alloc] initWithCapacity:kNumAsteroids];
      for (int i = 0; i < kNumAsteroids; ++i) {
       SKSpriteNode *   coin = [SKSpriteNode spriteNodeWithImageNamed:@"+10Coin.png"];
          
          coin.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:17.0];
          
          coin.physicsBody.categoryBitMask=EntityCategoryCoin;
          coin.physicsBody.collisionBitMask=0;
          coin.physicsBody.contactTestBitMask=EntityCategoryPlayer;
          coin.hidden = YES;
          coin.zPosition=10;
          [coin setXScale:0.5];
          [coin setYScale:0.5];
          [_coins addObject:coin];
          [self addChild:coin];
          
    }

   coinMinus    = [[NSMutableArray alloc] initWithCapacity:kNumAsteroids];
      for (int i = 0; i < kNumAsteroids; ++i) {
          SKSpriteNode *   coinMinuS = [SKSpriteNode spriteNodeWithImageNamed:@"+10Coin.png"];
        coinMinuS.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:17.0];
          
          coinMinuS.physicsBody.categoryBitMask=EntityCategoryCoinMinus;
          coinMinuS.physicsBody.collisionBitMask=0;
          coinMinuS.physicsBody.contactTestBitMask=EntityCategoryPlayer;
          coinMinuS.hidden = YES;
          coinMinuS.zPosition=10;
          [coinMinuS setXScale:0.5];
          [coinMinuS setYScale:0.5];
          [coinMinus addObject:coinMinuS];
          [self addChild:coinMinuS];
          
      }

      [self addChild:[self loadEmitterNode:@"stars1"]];
      [self addChild:[self loadEmitterNode:@"stars2"]];
      [self addChild:[self loadEmitterNode:@"stars3"]];
      [self setupHUD];
      

          if (connection==YES) {
          @try {
              // code that generates exception
          }
          @catch (NSException *exception) {
              if ([exception.name isEqualToString:NSInvalidArgumentException])
              {
                  // handle it
                
              }
              else
              {
                  @throw;
              }
          }
      
      }
  }
    

  return self;
}


    
#pragma mark - ChartBoostInterstitial method

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error{
    
//      [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
   
    isInterstitialFail=YES;
    
}

- (void)didCloseInterstitial:(CBLocation)location{
    isInterstitialFail=NO;
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    _hitGround = YES;
    _hitObstacle = YES;
    self.isPause=NO;
    self.scene.paused=NO;
    
}

- (void)didDisplayInterstitial:(CBLocation)location{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    isInterstitialFail=NO;
    
    
}

-(void)lifeAdded{

    [GameStatus sharedState].remLife  = [[NSUserDefaults standardUserDefaults]  integerForKey:@"life"];
    NSString *lifeValue = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults]integerForKey:@"life"]];
    self.lifeLabel.text=[NSString stringWithFormat:@"Life %@",lifeValue];
//    [self addChild:self.lifeLabel];

    
}

#pragma mark - ChartBoostDelegate  method

- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location{
    NSLog(@"in shouldDisplayRewardedVideo");
    
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    isChartBoostWatchSucess=NO;
    isChartBoostLoadSuccess=YES;
    return YES;
}

- (void)didDisplayRewardedVideo:(CBLocation)location{
    NSLog(@"didDisplayRewardedVideo");
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

}

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward{
    NSLog(@"didCompleteRewardedVideo");
    NSInteger life=[[NSUserDefaults standardUserDefaults ] integerForKey:@"life"];
    life = life+reward;
    
    [[NSUserDefaults standardUserDefaults] setInteger:life forKey:@"life"];
    [[NSUserDefaults standardUserDefaults]synchronize];

   [GameStatus sharedState].remScore=_score;
   
    [GameStatus sharedState].remTime=self.timeSec;
         isChartBoostWatchSucess=YES;

 }

- (void)didDismissRewardedVideo:(CBLocation)location{
    NSLog(@"didDismissRewardedVideo");
}

- (void)didCloseRewardedVideo:(CBLocation)location{
    NSLog(@"didCloseRewardedVideo");

    NSLog(@"");
    
    if (isChartBoostWatchSucess) {
        [self switchToNewGame];
        
    }else{
        [[AppDelegate sharedAppDelegate] hideHUDLoadingView];
  [Chartboost showInterstitial:CBLocationStartup];
 [self performSelector:@selector(chartBOOSTinterstitial) withObject:self afterDelay:4];
//    _hitGround = YES;
//      _hitObstacle = YES;
//      self.isPause=NO;
//    self.scene.paused=NO;
    }

}

- (void)didClickRewardedVideo:(CBLocation)location{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    [self.timer invalidate];
    _hitGround = YES;
    _hitObstacle = YES;
    self.isPause=NO;
    self.scene.paused=NO;

}

- (void)didClickInterstitial:(CBLocation)location{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    [self.timer invalidate];
    _hitGround = YES;
    _hitObstacle = YES;
    self.isPause=NO;
    self.scene.paused=NO;

}

- (void)didCacheRewardedVideo:(CBLocation)location{

    NSLog(@"catch success");
}


-(void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error{
    NSLog(@"didFailToLoadRewardedVideo");
//    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
//    [[AppDelegate sharedAppDelegate]showToastMessage:@"Sorry no video ads available at this time."];
//     [Chartboost showInterstitial:CBLocationStartup];
//  [self performSelector:@selector(chartBOOSTinterstitial) withObject:self afterDelay:4];

}


-(void)chartBOOSTinterstitial{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    if (isInterstitialFail) {
        
        
        _hitGround = YES;
        _hitObstacle = YES;
        self.isPause=NO;
        self.scene.paused=NO;
    }
}

-(void) createUI:(NSString *)senderName{
    
    if (!self.containerView) {
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(40, -300, 195, 258)];
        //self.containerView.userInteractionEnabled = YES;
        self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"display.png"]];
        [rootViewController.view addSubview:self.containerView];
        
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7,80, 240, 150)];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.font = [UIFont fontWithName:@"Transformers Movie" size:25];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.text=@"Do you want to continue \nwith out loosing the life ? ";
        self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.containerView addSubview:self.messageLabel];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width/2-10,35, 55, 90)];
        [self.profileImageView setImage:[UIImage imageNamed:@"playerDead.png"]];
        self.profileImageView.backgroundColor  = [UIColor clearColor];
        [self.containerView addSubview:self.profileImageView];

       
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
      
        self.cancelButton.frame = CGRectMake(20, 200, 100, 45);

         [self.cancelButton setImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.exclusiveTouch=YES;
        [self.containerView addSubview:self.cancelButton];
   
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
           self.acceptButton.frame = CGRectMake(140, 200, 100, 45);                [self.acceptButton setImage:[UIImage imageNamed:@"yes.png"] forState:UIControlStateNormal];
        [self.acceptButton addTarget:self action:@selector(acceptButton:) forControlEvents:UIControlEventTouchUpInside];
        self.acceptButton.exclusiveTouch=YES;
        [self.containerView addSubview:self.acceptButton];
    }
    
    
}

#pragma mark-
#pragma mark - Accept and Cancel Button
-(void)acceptButton:(UIButton *)button{

    self.acceptButton.selected=YES;
    
    self.containerView.hidden=YES;
    self.containerView=nil;
    self.acceptButton=nil;
    self.cancelButton=nil;
    self.messageLabel=nil;
    
    
    [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];

    [Chartboost showRewardedVideo:CBLocationStartup];
    [self performSelector:@selector(checkChartBoostSucceeded) withObject:self afterDelay:4];
}

-(void)checkChartBoostSucceeded{
    if (!isChartBoostLoadSuccess) {
    
//        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
        [[AppDelegate sharedAppDelegate]showToastMessage:@"Sorry no video ads available at this time."];

  [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                 _hitGround = YES;
            _hitObstacle = YES;
             self.isPause=NO;
            self.scene.paused=NO;

    }

}

-(void)cancelButtonClicked:(UIButton *)button{
    
    self.cancelButton.selected=YES;
    self.containerView.hidden=YES;
    self.containerView=nil;
    self.acceptButton=nil;
    self.cancelButton=nil;
    self.messageLabel=nil;
    

   BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
    if (connection==YES) {
        [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];
        [Chartboost showInterstitial:CBLocationStartup];
          [self performSelector:@selector(chartBOOSTinterstitial) withObject:self afterDelay:3];
    }
    
    NSString *dateStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"strtdate"];
   if ([dateStr isEqualToString:@"0"]) {//if3
    
        NSDate* now = [NSDate date];
        NSDateFormatter *formate = [[NSDateFormatter alloc] init];
        [formate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSString *dateStr = [formate stringFromDate:now];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"strtdate"];
        [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"firedate"];
        [[NSUserDefaults standardUserDefaults]synchronize];

   }
}

#pragma mark - NSTimer method
//#pragma NSTimer method

- (void)timerTick:(NSTimer *)timer {
    
    
    if (_gameState==GameStatePlay) {
       
    if (self.timeSec >= 0)
    {
        if(timerStop==0)
        {
        self.timeSec--;
            if (self.timeSec==-1) {

            }else{
              NSString* timeNow = [NSString stringWithFormat:@"             %02d:%02d", self.timeMin, self.timeSec];
                    self.time.text=timeNow;
            }
      

        self.state=NO;
        
        if (_isImmunePowerOn==YES&&_hitGround==NO) {
            if ([GameStatus sharedState].levelNumber<=10) {
                if (_imunePowerSec==7) {
                    [_player removeActionForKey:@"movingBluePlyer"];
                    [_player runAction:[SKAction repeatActionForever:
                                        [SKAction animateWithTextures:powerRedFrames
                                                         timePerFrame:0.2f
                                                               resize:YES
                                                              restore:YES]] withKey:@"movingRedPlyer"];
                }
                if (_imunePowerSec==10) {
                    _isImmunePowerOn=NO;

                   [_player removeActionForKey:@"movingRedPlyer"];
                    [_player runAction:[SKAction repeatActionForever:
                                        [SKAction animateWithTextures:simplePlayerFrames
                                                         timePerFrame:0.2f
                                                               resize:YES
                                                              restore:YES]] withKey:@"movingNormalPlyer"];
            }
    
             
            }else{
                            if (_imunePowerSec==3) {
                    [_player removeActionForKey:@"movingBluePlyer"];
                    [_player runAction:[SKAction repeatActionForever:
                        [SKAction animateWithTextures:powerRedFrames
                                                         timePerFrame:0.2f
                                                               resize:YES
                                                              restore:YES]] withKey:@"movingRedPlyer"];
                }
                if (_imunePowerSec==6) {
                   _isImmunePowerOn=NO;
                    [_player removeActionForKey:@"movingRedPlyer"];
                    [_player runAction:[SKAction repeatActionForever:
                                        [SKAction animateWithTextures:simplePlayerFrames
                                                         timePerFrame:0.2f
                                                               resize:YES
                                                              restore:YES]] withKey:@"movingNormalPlyer"];
                    
                }

            }   _imunePowerSec++;

        }
    }
}
    if (self.timeSec==-1) {
        _gameState=GameStateGameOver;
        [ _musicPlayer stop];
        [_player removeAllActions];
        [self popUPForLevelCompletion];
        NSInteger levelClear=[[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
        if (levelClear<[GameStatus sharedState].levelNumber+1) {
              [[NSUserDefaults standardUserDefaults] setInteger:[GameStatus sharedState].levelNumber +1 forKey:@"levelClear"];
        }
      
        [[NSUserDefaults standardUserDefaults]synchronize];
        SKAction *wait=[SKAction waitForDuration:.50];
        [self runAction:wait];
        [self switchToShowScore:2];
        
        
    }
        
    }
    
}



#pragma mark - StarComing method

- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
        //do some view specific tweaks
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width+100, self.size.height);
    
    return emitterNode;
    
}

#pragma mark - MusicButton method

-(void)musicButtonToggle:(SKSpriteNode *)node{
    if (self.num==1) {
        [_musicPlayer stop];
// [self.missileButton setTexture:[SKTexture textureWithImageNamed:@"missileButtonPressed"]];
        
         //        [self.button setImage:[UIImage imageNamed:@"musicoff.png"] forState:UIControlStateNormal];
        self.num=2;
        self.musicButton.texture=self.texure2;
    }
    else{
        [_musicPlayer play];
//       [self.button setImage:[UIImage imageNamed:@"music"] forState:UIControlStateNormal];
              self.musicButton.texture=self.texure1;
        self.num=1;
    }
    
}


- (void)setupSombrero {

  _sombrero = [SKSpriteNode spriteNodeWithImageNamed:@"Smoke"];
  _sombrero.position = CGPointMake(-27, -8);
  [_player addChild:_sombrero];
  

}
- (void)playMusic
{
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
        
    }

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
        } else {
        _musicPlayer.delegate = self;
        [_musicPlayer prepareToPlay];
     [_musicPlayer play];
    }
}

#pragma mark - Setup methods

- (void)setupBackground {
    
    SKSpriteNode  *background ;
    if([UIScreen mainScreen].bounds.size.height>500){
        
        if ([GameStatus sharedState].levelNumber<=10) {
        background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg1.png"];
//
        }else if ([GameStatus sharedState].levelNumber>10&&[GameStatus sharedState].levelNumber<=20){
            background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_2_568.png"];

        
        }else if([GameStatus sharedState].levelNumber>20&&[GameStatus sharedState].levelNumber<=30){
            background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_4_568.png"];

        }
        else if ([GameStatus sharedState].levelNumber>30&&[GameStatus sharedState].levelNumber<=40){
            background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_3_568.png"];

        }
    }
    else{
         if ([GameStatus sharedState].levelNumber<=10) {
             background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg.png"];

         }else if ([GameStatus sharedState].levelNumber>10&&[GameStatus sharedState].levelNumber<=20){
             background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_2_480.png"];

             
         }else if([GameStatus sharedState].levelNumber>20&&[GameStatus sharedState].levelNumber<=30){
             background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_4_480.png"];

         }
         else if ([GameStatus sharedState].levelNumber>30&&[GameStatus sharedState].levelNumber<=40){
             background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg_3_480.png"];

         }

    }

  background.anchorPoint = CGPointMake(0.5, 1);
  background.position = CGPointMake(self.size.width/2, self.size.height);
  background.zPosition = LayerBackground;
  [_worldNode addChild:background];
  
  _playableStart = self.size.height - background.size.height;
//    NSLog(@"playable start %f",_playableStart);
    _playableHeight = background.size.height;
//    _playableHeight = self.size.height;
//    NSLog(@"playable height %f",_playableHeight);

  // 1
  CGPoint lowerLeft = CGPointMake(0, _playableStart);
  CGPoint lowerRight = CGPointMake(self.size.width, _playableStart);
    
//    CGPoint lowerLeft = CGPointMake(0, 0);
//    CGPoint lowerRight = CGPointMake(self.size.width,0);

  self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:lowerLeft toPoint:lowerRight];
   self.physicsBody.categoryBitMask = EntityCategoryGround;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayer;

}

- (void)setupForeground {
  for (int i = 0; i < kNumForegrounds; ++i) {
    SKSpriteNode *foreground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground"];
    foreground.anchorPoint = CGPointMake(0, 1);
    foreground.position = CGPointMake(i * self.size.width, _playableStart);
    foreground.zPosition = LayerForeground;
    foreground.name = @"Foreground";
    [_worldNode addChild:foreground];
  }
}

- (void)setupPlayer {
  _player = [SKSpriteNode spriteNodeWithImageNamed:@"Astronaut.png"];
    
    if([UIScreen mainScreen].bounds.size.height>500){
        
        _player.position = CGPointMake(self.size.width * 0.2, _playableHeight * 0.6 + _playableStart);

    }
    else{
        
        _player.position = CGPointMake(self.size.width * 0.2, _playableHeight * 0.5 + _playableStart);
  
    }
    

  _player.zPosition = 50;
  [_worldNode addChild:_player];
    [self configureEmitters];
  CGFloat offsetX = _player.frame.size.width * _player.anchorPoint.x;
  
  CGFloat offsetY = _player.frame.size.height * _player.anchorPoint.y;
    
  CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 32 - offsetX, 52 - offsetY);
    CGPathAddLineToPoint(path, NULL, 42 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 43 - offsetX, 37 - offsetY);
    CGPathAddLineToPoint(path, NULL, 40 - offsetX, 31 - offsetY);
    CGPathAddLineToPoint(path, NULL, 33 - offsetX, 30 - offsetY);
    CGPathAddLineToPoint(path, NULL, 33 - offsetX, 25 - offsetY);
    CGPathAddLineToPoint(path, NULL, 25 - offsetX, 14 - offsetY);
    CGPathAddLineToPoint(path, NULL, 21 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 11 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 31 - offsetY);
    CGPathAddLineToPoint(path, NULL, 19 - offsetX, 47 - offsetY);
  CGPathCloseSubpath(path);
    
    if(self.scene.paused==NO)
    {

  _player.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
  _player.physicsBody.categoryBitMask = EntityCategoryPlayer;
  _player.physicsBody.collisionBitMask = 0;
  _player.physicsBody.contactTestBitMask = EntityCategoryObstacle | EntityCategoryGround|EntityCategoryImunePower;
  
   }
    playerSize=_player.size;
}

- (void)setupSounds {
    
  //_dingAction = [SKAction playSoundFileNamed:@"ding.wav" waitForCompletion:NO];
  _flapAction = [SKAction playSoundFileNamed:@"tapSound.wav" waitForCompletion:NO];
  _whackAction = [SKAction playSoundFileNamed:@"whack.wav" waitForCompletion:NO];
  _fallingAction = [SKAction playSoundFileNamed:@"dead.wav" waitForCompletion:NO];
  _hitGroundAction = [SKAction playSoundFileNamed:@"fall.wav" waitForCompletion:NO];
  _popAction = [SKAction playSoundFileNamed:@"pop.wav" waitForCompletion:NO];
  _coinAction = [SKAction playSoundFileNamed:@"coin.wav" waitForCompletion:NO];
  _powerAction = [SKAction playSoundFileNamed:@"power.wav" waitForCompletion:NO];
}

- (void)setupScoreLabel {
  _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Transformers Movie"];
  _scoreLabel.fontColor = [UIColor whiteColor];
    _scoreLabel.fontSize=40;
  _scoreLabel.position = CGPointMake(self.size.width/2, self.size.height - kMargin);
  _scoreLabel.text = [NSString stringWithFormat:@"%d",_score];
  _scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  _scoreLabel.zPosition = LayerUI;
  [_worldNode addChild:_scoreLabel];
}

- (void)setupTutorial {
    
  SKSpriteNode *tutorial = [SKSpriteNode spriteNodeWithImageNamed:@"tap.png"];
//SKSpriteNode *tutorial = [SKSpriteNode
//                          spriteNodeWithImageNamed:@"testext.png"];

    if([UIScreen mainScreen].bounds.size.height>500){
      
        tutorial.position = CGPointMake(self.size.width * 0.2, _playableHeight * 0.77 + _playableStart -170);
    }
    else{
        
        tutorial.position = CGPointMake(self.size.width * 0.2, _playableHeight * 0.7 + _playableStart -170);
        
    }

//SKSpriteNode *
  tutorial.name = @"Tutorial";
  tutorial.zPosition = 10;
  [_worldNode addChild:tutorial];
  
}

#pragma mark - Gameplay

- (SKSpriteNode *)createObstacle {
    
   
    int imgType = 0;
    
    if (arc4random_uniform != NULL){
        imgType = arc4random_uniform (5);
//        NSLog(@"if imgType is %d",imgType);
    }
    else{
        imgType = (arc4random() % 5);
//         NSLog(@"else imgType is %d",imgType);
    }
    
    NSString *loadImageType = [NSString stringWithFormat:@"Debris%d",imgType];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:loadImageType];
    sprite.zPosition = LayerObstacle;

    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
//    imgType=1;
    switch (imgType) {
        case 0:
            CGPathMoveToPoint(path, NULL, 27 - offsetX, 315 - offsetY);
//            NSLog(@"move to the point %f and %f",27-offsetX,315-offsetY);
            CGPathAddLineToPoint(path, NULL, 49 - offsetX, 268 - offsetY);
//            NSLog(@"add path x %f and y %f",49-offsetX,268-offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 232 - offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 47 - offsetY);
            CGPathAddLineToPoint(path, NULL, 47 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 41 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 95 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 197 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 234 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 290 - offsetY);
            break;
        case 1:
            CGPathMoveToPoint(path, NULL, 35 - offsetX, 312 - offsetY);
//              NSLog(@"move to the point %f and %f",27-offsetX,315-offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 296 - offsetY);
            CGPathAddLineToPoint(path, NULL, 52 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 6 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 97 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 307 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 315 - offsetY);
            break;
        case 2:
            CGPathMoveToPoint(path, NULL, 24 - offsetX, 306 - offsetY);
//              NSLog(@"move to the point %f and %f",27-offsetX,315-offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 283 - offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 181 - offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 47 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 188 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 262 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 299 - offsetY);
            break;
        case 3:
            CGPathMoveToPoint(path, NULL, 53 - offsetX, 287 - offsetY);
//              NSLog(@"move to the point %f and %f",27-offsetX,315-offsetY);
            CGPathAddLineToPoint(path, NULL, 50 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 41 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 102 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 290 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 305 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 311 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 312 - offsetY);
            CGPathAddLineToPoint(path, NULL, 43 - offsetX, 306 - offsetY);
            break;
        case 4:
            CGPathMoveToPoint(path, NULL, 25 - offsetX, 314 - offsetY);
//              NSLog(@"move to the point %f and %f",27-offsetX,315-offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 294 - offsetY);
            CGPathAddLineToPoint(path, NULL, 52 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 48 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 31 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 154 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 216 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 278 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 298 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 310 - offsetY);
            break;
        default:
            break;
    }
    
    CGPathCloseSubpath(path);
    
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    sprite.physicsBody.categoryBitMask = EntityCategoryObstacle;
    sprite.physicsBody.collisionBitMask = 0;
    sprite.physicsBody.contactTestBitMask = EntityCategoryPlayer;
    
    return sprite;
}

-(void)popForlife{

    SKSpriteNode *popUp=[[SKSpriteNode alloc] initWithImageNamed:@"loslife1.png"];
    popUp.position=CGPointMake(160,240);
    popUp.zPosition=50;
    [self addChild:popUp];
    SKAction *delay=[SKAction waitForDuration:0.50];
    SKAction *remove=[SKAction removeFromParent];
    SKAction *sequence=[SKAction sequence:@[delay,remove]];
    [popUp runAction:sequence];
    
    
    
}



-(void)popUPForLevelCompletion{
    SKSpriteNode *popUp;
       if([UIScreen mainScreen].bounds.size.height<500){
     popUp=[[SKSpriteNode alloc] initWithImageNamed:@"wonderful1.png"];
       }else{
    popUp=[[SKSpriteNode alloc] initWithImageNamed:@"wonderfull.png"];
       }
    popUp.position=CGPointMake(160,240);
    popUp.zPosition=50;
    [self addChild:popUp];
    SKAction *delay=[SKAction waitForDuration:1.0];
    SKAction *remove=[SKAction removeFromParent];
    SKAction *sequence=[SKAction sequence:@[delay,remove]];
    [popUp runAction:sequence];
   }

- (void)startSpawning {
    
    if ([GameStatus sharedState].levelNumber<=5) {
        
        firstDelay = [SKAction waitForDuration: 1.0-0.01*[GameStatus sharedState].levelNumber  ];
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        everyDelay = [SKAction waitForDuration:1.80-0.08*[GameStatus sharedState].levelNumber];
        
//        NSLog(@"speed 2nd %f",10.0-0.01*[GameStatus sharedState].levelNumber );
        
    }
    if ([GameStatus sharedState].levelNumber>=6 && [GameStatus sharedState].levelNumber<10) {
        
        firstDelay = [SKAction waitForDuration: 1.0-0.01*[GameStatus sharedState].levelNumber  ];
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        everyDelay = [SKAction waitForDuration:1.80-0.05*[GameStatus sharedState].levelNumber];
        
        //        NSLog(@"speed 2nd %f",10.0-0.01*[GameStatus sharedState].levelNumber );
        
    }

    
    
    if ([GameStatus sharedState].levelNumber>=10&&[GameStatus sharedState].levelNumber<=16)
    {
        firstDelay = [SKAction waitForDuration: 0.5];
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        
         everyDelay = [SKAction waitForDuration:1.80-0.01*[GameStatus sharedState].levelNumber];
       
        if ([GameStatus sharedState].levelNumber==16) {
            everyDelay= [SKAction waitForDuration:0.9];
        }
        if ([GameStatus sharedState].levelNumber==15) {
            everyDelay= [SKAction waitForDuration:0.8];
        }
        
      }
    if ([GameStatus sharedState].levelNumber>=17&&[GameStatus sharedState].levelNumber<=25)
    {
        firstDelay = [SKAction waitForDuration: 1.0-0.01*[GameStatus sharedState].levelNumber  ];
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        
        everyDelay = [SKAction waitForDuration:1.80-0.01*[GameStatus sharedState].levelNumber];
        if ([GameStatus sharedState].levelNumber>=22) {
            firstDelay = [SKAction waitForDuration: 0.8];
            spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
            
            everyDelay = [SKAction waitForDuration:1.00];
            NSLog(@"everyDelay-======-");

        }
        if ([GameStatus sharedState].levelNumber==20) {
            firstDelay = [SKAction waitForDuration: 0.8];
            spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
            
            everyDelay = [SKAction waitForDuration:1.5];
        }
    }
    
    if ([GameStatus sharedState].levelNumber>25&&[GameStatus sharedState].levelNumber<=32) {
        
        firstDelay = [SKAction waitForDuration: 1.0];
//        NSLog(@"speed 1st  %f",1.0-0.02*[GameStatus sharedState].levelNumber );
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        everyDelay = [SKAction waitForDuration:1.1];
//        NSLog(@"speed 2nd %f",10.0-0.02*[GameStatus sharedState].levelNumber );
//
        
    }
    if ([GameStatus sharedState].levelNumber>=33 &&[GameStatus sharedState].levelNumber<=40) {
               
        
        firstDelay = [SKAction waitForDuration: 0.9 ];
        
       
        spawn = [SKAction performSelector:@selector(spawnobstacle) onTarget:self];
        everyDelay = [SKAction waitForDuration:0.7];
      
    }
    SKAction *spawnSequence = [SKAction sequence:@[spawn, everyDelay]];
    SKAction *foreverSpawn = [SKAction repeatActionForever:spawnSequence];
    SKAction *overallSequence = [SKAction sequence:@[firstDelay, foreverSpawn]];
    [self runAction:overallSequence withKey:@"Spawn"];
    
    
}
-(void)textureAtlas{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    SKTexture *f1 = [atlas textureNamed:@"element1.png"];
   SKTexture *f2 = [atlas textureNamed:@"element2.png"];
    monsterWalkTextures = @[f1,f2];


}

- (void)spawnobstacle {
    
    if (timerStop==1) {
        return ;
    }
    float bottomObstacleMax;
    self.obstacleCross=YES;
    
    SKSpriteNode *bottomObstacle = [self createObstacle];
    bottomObstacle.name = @"BottomObstacle";
    bottomObstacle.zPosition=10;
    
    float startX = self.size.width + bottomObstacle.size.width/2;
    float bottomObstacleMin = (_playableStart - bottomObstacle.size.height/2) + _playableHeight * kBottomObstacleMinFraction;
    
    if ([GameStatus sharedState].levelNumber>25&&[GameStatus sharedState].levelNumber<=32) {
        bottomObstacleMax = (_playableStart - (bottomObstacle.size.height*3)/4) + _playableHeight * kBottomObstacleMaxFraction;
    }
    else
    {
        bottomObstacleMax = (_playableStart +bottomObstacle.size.height/2) + _playableHeight * kBottomObstacleMaxFraction;
    }
    
        //   NSLog(@"bottom obstacle max %f",bottomObstacleMax);
    float yPos;
    yPos=RandomFloatRange(bottomObstacleMin, bottomObstacleMax);
    
    [_worldNode addChild:bottomObstacle];
    
    SKSpriteNode *topObstacle = [self createObstacle];
    topObstacle.name = @"TopObstacle";
        //  topObstacle.zRotation = DegreesToRadians(180);
    topObstacle.zPosition=10;
    
    [_worldNode addChild:topObstacle];
    float moveX= self.size.width + bottomObstacle.size.width;
    
    
        //=======================================================
    float h = 1.5;
    int a = (int)[GameStatus sharedState].levelNumber/5;
    float b = a/5;
    float c = b/10;
    h = c + 1.5;
    
     if ([GameStatus sharedState].levelNumber<=9) {
    
         kGroundSpeed=150.0;
         
         float startX = self.size.width + bottomObstacle.size.width/2;
         float bottomObstacleMin;
         
         topObstacle.zRotation = DegreesToRadians(180);
         
         if ([UIScreen mainScreen].bounds.size.height>500) {
             
             bottomObstacleMin = (_playableStart - bottomObstacle.size.height/h) + _playableHeight * kBottomObstacleMinFraction+30;
         }
         else{
             bottomObstacleMin = (_playableStart - bottomObstacle.size.height/h) + _playableHeight * kBottomObstacleMinFraction;
        }
         float bottomObstacleMax = (_playableStart - bottomObstacle.size.height/2) + _playableHeight * kBottomObstacleMaxFraction;
       
         bottomObstacle.position = CGPointMake(startX, RandomFloatRange(bottomObstacleMin, bottomObstacleMax));
         
         float moveDuration = (moveX / kGroundSpeed) - 0.02*[GameStatus sharedState].levelNumber ;
         
         if ([UIScreen mainScreen].bounds.size.height>500) {
             
              bottomObstacle.position = CGPointMake(startX, RandomFloatRange(bottomObstacleMin, bottomObstacleMax)+55);
             
             topObstacle.position = CGPointMake(startX,( bottomObstacle.position.y + bottomObstacle.size.height/h + topObstacle.size.height/2 + _player.size.height * kGapMultiplier)-75);
             if (_isImmunePowerOn==YES) {
                  topObstacle.position = CGPointMake(startX, (bottomObstacle.position.y + bottomObstacle.size.height/h + topObstacle.size.height/2 + playerSize.height * kGapMultiplier)-20);
             }
         }
         else{
             bottomObstacle.position = CGPointMake(startX, (RandomFloatRange(bottomObstacleMin, bottomObstacleMax))+55);
             topObstacle.position = CGPointMake(startX,( bottomObstacle.position.y + bottomObstacle.size.height/h + topObstacle.size.height/2 + _player.size.height * kGapMultiplier)-75);
             if (_isImmunePowerOn==YES) {
                 topObstacle.position = CGPointMake(startX,( bottomObstacle.position.y + bottomObstacle.size.height/h + topObstacle.size.height/2 + playerSize.height * kGapMultiplier)-70);
             }
         }
         

         
         
    if ([GameStatus sharedState].levelNumber<=2) {
        kGroundSpeed=150.0;
        
        
        SKAction *sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration],[SKAction removeFromParent]]];
        
        [topObstacle runAction:sequence];
        [bottomObstacle runAction:sequence];
        
    }

    //================
    if ([GameStatus sharedState].levelNumber<=5&&[GameStatus sharedState].levelNumber>2) {
        kGroundSpeed=135.0;
        _debrisCount++;
        
        if (_debrisCount%5==0&&_debrisCount/5>=1) {
           
            SKAction *movetoY;
            SKAction *movtoYReverse;
            SKAction *movetoYBottom;
            SKAction *movetoYBottomReverse;
            if ([GameStatus sharedState].levelNumber==3) {
                movetoY=[SKAction moveToY:topObstacle.position.y-80 duration:0.9];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y+130 duration:1.2];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y-80 duration:0.9];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y+130 duration:1.2];

            }else if ([GameStatus sharedState].levelNumber==4){
                movetoY=[SKAction moveToY:topObstacle.position.y-80 duration:0.8];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y+130 duration:1.1];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y-80 duration:0.8];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y+130 duration:1.1];
            }else if ([GameStatus sharedState].levelNumber==5){
                movetoY=[SKAction moveToY:topObstacle.position.y-80 duration:0.7];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y+130 duration:1.0];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y-80 duration:0.7];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y+130 duration:1.0];
            }
            //Top
            SKAction *seq=[SKAction sequence:@[movetoY,movtoYReverse]];
            
            SKAction *repeat=[SKAction repeatActionForever:seq];
            SKAction *group=[SKAction group:@[repeat, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
            SKAction *sequencetop = [SKAction sequence:@[group,[SKAction removeFromParent]]];
            
            
            //Bottom
                      SKAction *seqbottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqbottom];
            SKAction *groupBottom=[SKAction group:@[repeatBottom, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
            
            SKAction *sequencebotom = [SKAction sequence:@[groupBottom,[SKAction removeFromParent]]];
            
            [topObstacle runAction:sequencetop];
            [bottomObstacle runAction:sequencebotom];

        }
        else{
        
            SKAction *sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration],[SKAction removeFromParent]]];
            
            [topObstacle runAction:sequence];
            [bottomObstacle runAction:sequence];
        
        }
    }

    //==================
    if ([GameStatus sharedState].levelNumber<=9&&[GameStatus sharedState].levelNumber>5) {
        kGroundSpeed=150.0;
        _debrisCount++;
        SKAction *movetoY;
        SKAction *movtoYReverse;
        SKAction *movetoYBottom;
        SKAction *movetoYBottomReverse;
        if ((_debrisCount>2)&&(_debrisCount%2!=0)) {
            //Top
            if ([GameStatus sharedState].levelNumber==6) {
                
                movetoY=[SKAction moveToY:topObstacle.position.y+90 duration:0.9];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y-90 duration:1.3];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+90 duration:0.9];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-90 duration:1.3];
                
            }else if ([GameStatus sharedState].levelNumber==7){
            
                movetoY=[SKAction moveToY:topObstacle.position.y+90 duration:0.8];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y-90 duration:1.2];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+90 duration:0.8];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-90 duration:1.2];
                
            }else if([GameStatus sharedState].levelNumber==8){
            
                movetoY=[SKAction moveToY:topObstacle.position.y+90 duration:0.7];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y-90 duration:1.1];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+90 duration:0.7];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-90 duration:1.1];
                
            }else if ([GameStatus sharedState].levelNumber==9){
            
                movetoY=[SKAction moveToY:topObstacle.position.y+90 duration:0.6];
                movtoYReverse=[SKAction moveToY:topObstacle.position.y-90 duration:1.0];
                movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+90 duration:0.6];
                movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-90 duration:1.0];
                
            }
           
            
            SKAction *seq=[SKAction sequence:@[movetoY,movtoYReverse]];
            
            SKAction *repeat=[SKAction repeatActionForever:seq];
            SKAction *group=[SKAction group:@[repeat, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
            SKAction *sequencetop = [SKAction sequence:@[group,[SKAction removeFromParent]]];
            //   Bottom
            
            SKAction *seqbottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqbottom];
            SKAction *groupBottom=[SKAction group:@[repeatBottom, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
            
            SKAction *sequencebotom = [SKAction sequence:@[groupBottom,[SKAction removeFromParent]]];
            
            [topObstacle runAction:sequencetop];
            [bottomObstacle runAction:sequencebotom];
            
            
        }else{
        
        
            SKAction *sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration],[SKAction removeFromParent]]];
            
            [topObstacle runAction:sequence];
            [bottomObstacle runAction:sequence];
        }
        
     }
         
  }
        //[GameStatus sharedState].levelNumber>=17&&[GameStatus sharedState].levelNumber<=25)=================================================================
    if([GameStatus sharedState].levelNumber>=33&&[GameStatus sharedState].levelNumber<=40)
    {            //======================new added
        _debrisCount++;
           float moveDuration1 = (moveX / kGroundSpeed) - 0.02*[GameStatus sharedState].levelNumber ;
           SKAction *sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration1],[SKAction removeFromParent]]];
        if ([UIScreen mainScreen].bounds.size.height>500) 
        {
            yPos=RandomFloatRange(20,self.size.height/3);
        }
        else
        {
            yPos=RandomFloatRange(bottomObstacleMin,self.size.height*3/8);
        }
 
        kGroundSpeed=125.0+[GameStatus sharedState].levelNumber;
        
        bottomObstacle.position = CGPointMake(startX,yPos);
        topObstacle.position=CGPointMake(startX,( (yPos+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/2)+41-[GameStatus sharedState].levelNumber-10)-10);
        if (_isImmunePowerOn) {
            
            topObstacle.position=CGPointMake(startX, (yPos+playerSize.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/2)+41-[GameStatus sharedState].levelNumber-10);
        }
            if (_debrisCount>1&&_debrisCount%3==0) {
                      SKAction *movetoY=[SKAction moveToY:(yPos+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/2)-40 duration:0.5];
            SKAction *movtoYReverse=[SKAction moveToY:(yPos+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/2) duration:0.5 ];
            SKAction *movetoY1=[SKAction moveToY:(yPos+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/2)-50 duration:0.5];
            
            SKAction *seq=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seq2=[SKAction sequence:@[movetoY1,movtoYReverse]];
            SKAction *seq3=[SKAction sequence:@[seq,seq2]];
            SKAction *repeat=[SKAction repeatActionForever:seq3];
            SKAction *group=[SKAction group:@[repeat, [SKAction moveByX:-moveX y:0 duration:moveDuration1]]];
            SKAction *sequencetop = [SKAction sequence:@[group,[SKAction removeFromParent]]];
            [topObstacle runAction:sequencetop];
           
//            =====================
            SKAction *movetoYBottom=[SKAction moveToY:yPos-40 duration:0.5];
            SKAction *movtoYReverseBottom=[SKAction moveToY:yPos duration:0.5 ];
            SKAction *movetoYBottom1=[SKAction moveToY:yPos-50 duration:0.5];
            SKAction *seq1=[SKAction sequence:@[movetoYBottom,movtoYReverseBottom]];
            SKAction *seq4=[SKAction sequence:@[movetoYBottom1,movtoYReverseBottom]];
            SKAction *seq5=[SKAction sequence:@[seq1,seq4]];
            SKAction *repeat1=[SKAction repeatActionForever:seq5];
            SKAction *group1=[SKAction group:@[repeat1, [SKAction moveByX:-moveX y:0 duration:moveDuration1]]];
            SKAction *sequence1 = [SKAction sequence:@[group1,[SKAction removeFromParent]]];
           [bottomObstacle runAction:sequence1];


        }else{
        
            [bottomObstacle runAction:sequence];
            [topObstacle runAction:sequence];
        
        }
        
                
    }
    
    if ([GameStatus sharedState].levelNumber>=10&&[GameStatus sharedState].levelNumber<=16) {
        _debrisCount++;
        h = h+0.3;
        kGroundSpeed=60.0+[GameStatus sharedState].levelNumber;
        
        float moveDuration = moveX / kGroundSpeed;
        float ypos1=RandomFloatRange(-80,80);
        topObstacle.zRotation=DegreesToRadians(165);
        bottomObstacle.zRotation=DegreesToRadians(165);
        SKAction *sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration -0.15*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]]];
        
        if ([UIScreen mainScreen].bounds.size.height>500) {
            
          bottomObstacle.position = CGPointMake(startX-50,ypos1+20);
            if ([GameStatus sharedState].levelNumber==10) {
                topObstacle.position=CGPointMake(startX+60,( (20+_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-25);
                if (_isImmunePowerOn==YES) {
                    topObstacle.position=CGPointMake(startX+60,( (20+playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-20);
                    
                }

            }else{
          topObstacle.position=CGPointMake(startX+60,( (20+_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-25);
            if (_isImmunePowerOn==YES) {
             topObstacle.position=CGPointMake(startX+60,( (20+playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1));
            
            }
                
            }
        }
        else{
        
            bottomObstacle.position = CGPointMake(startX-50,ypos1);
            if ([GameStatus sharedState].levelNumber==10) {
                topObstacle.position=CGPointMake(startX+60, ((20+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-20);
                if (_isImmunePowerOn==YES) {
                    topObstacle.position=CGPointMake(startX+60, ((20+playerSize.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1));
                }
            }else{
                
                topObstacle.position=CGPointMake(startX+60, ((20+_player.size.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-18);
                if (_isImmunePowerOn==YES) {
                    topObstacle.position=CGPointMake(startX+60, ((20+playerSize.height*kGapMultiplier+bottomObstacle.size.height/2+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber-60+ypos1)-18);
                }

            
            
            }
            
        
        SKAction *movetoY;
        SKAction *movtoYReverse;
        SKAction *movetoYBottom;
        SKAction *movetoYBottomReverse;

        
    if ([GameStatus sharedState].levelNumber>=10&&[GameStatus sharedState].levelNumber<=13) {
            if (_debrisCount%5==0||_debrisCount%5==4) {

            movetoY=[SKAction moveToY:topObstacle.position.y+70 duration:1.6-(0.1*[GameStatus sharedState].levelNumber)];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y-70 duration:2.0-(0.1*[GameStatus sharedState].levelNumber)];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+70 duration:1.6-(0.1*[GameStatus sharedState].levelNumber)];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-70 duration:2.0-(0.1*[GameStatus sharedState].levelNumber)];
            
           
            SKAction *seq1=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seq4=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
                SKAction *repeatTop=[SKAction repeatActionForever:seq1];
                SKAction *repeatBottom=[SKAction repeatActionForever:seq4];
            SKAction *groupActionTop=[SKAction group:@[sequence,repeatTop]];
            SKAction *groupActionBottom=[SKAction group:@[sequence,repeatBottom]];
            [topObstacle runAction:groupActionTop];
            [bottomObstacle runAction:groupActionBottom];
            }
            else{
                [topObstacle runAction:sequence];
                [bottomObstacle runAction:sequence];
            }
        }
//        =================================
            
//        -=============================-
              if ([GameStatus sharedState].levelNumber>=14&&[GameStatus sharedState].levelNumber<=16) {
                  
                  kGroundSpeed=70.0+[GameStatus sharedState].levelNumber;
                  
                   moveDuration = moveX / kGroundSpeed;
  sequence = [SKAction sequence:@[[SKAction moveByX:-moveX y:0 duration:moveDuration -0.15*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]]];
                  
                 if ((_debrisCount>2)&&(_debrisCount%2!=0))  {
                    
                    movetoY=[SKAction moveToY:topObstacle.position.y+90 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
                    movtoYReverse=[SKAction moveToY:topObstacle.position.y-90 duration:2.7-(0.1*[GameStatus sharedState].levelNumber)];
                    movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+90 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
                    movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-90 duration:2.7-(0.1*[GameStatus sharedState].levelNumber)];
                    
                   
                    SKAction *seq1=[SKAction sequence:@[movetoY,movtoYReverse]];
                    SKAction *seq4=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
                    SKAction *repeatTop=[SKAction repeatActionForever:seq1];
                    SKAction *repeatBottom=[SKAction repeatActionForever:seq4];
                    SKAction *groupActionTop=[SKAction group:@[sequence,repeatTop]];
                    SKAction *groupActionBottom=[SKAction group:@[sequence,repeatBottom]];
                    [topObstacle runAction:groupActionTop];
                    [bottomObstacle runAction:groupActionBottom];
                }
                else{
                    [topObstacle runAction:sequence];
                    [bottomObstacle runAction:sequence];
                }
            }

        }
        
        
        
    }
    
        //==================================================================
    
    if ([GameStatus sharedState].levelNumber>=17&&[GameStatus sharedState].levelNumber<=25) {
        _debrisCount++;
        h = h + 0.3;
        float ypos1=40;
        kGroundSpeed=50.0+[GameStatus sharedState].levelNumber;
        float moveDuration = moveX / kGroundSpeed;
        
      SKAction *movetoY;
        SKAction *movtoYReverse;
        SKAction *movetoYBottom;
        SKAction *movetoYBottomReverse;

        SKAction *sequence = [SKAction sequence:@[
                                                  [SKAction moveByX:-moveX y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]
                                                  ]];
        SKAction *sequence1 = [SKAction sequence:@[
                                                   [SKAction moveByX:-moveX y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber]]];
        SKAction *sequence2=[SKAction sequence:@[sequence1,[SKAction removeFromParent]]];
        
    
        
        bottomObstacle.position = CGPointMake(startX-30,ypos1+10);
       
        topObstacle.position=CGPointMake(startX+55, ((_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
        if (_isImmunePowerOn) {
             topObstacle.position=CGPointMake(startX+55, ((playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
        }
        
        movetoY=[SKAction moveToY:topObstacle.position.y-50 duration:1.9-(0.1*[GameStatus sharedState].levelNumber)];
        movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
        movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+50 duration:1.9-(0.1*[GameStatus sharedState].levelNumber)];
        movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
//        SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
//        SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
//        SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
//        SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
        

        if ([GameStatus sharedState].levelNumber==17) {
            [topObstacle runAction:sequence2];
            [bottomObstacle runAction:sequence];
        }else if ([GameStatus sharedState].levelNumber==18)
        {
            
            movetoY=[SKAction moveToY:topObstacle.position.y-50 duration:1.9-(0.1*[GameStatus sharedState].levelNumber)];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+50 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.2];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
//            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];

            
                 if (_debrisCount%4==0 ) {
                     [topObstacle runAction:sequence2];
                     [bottomObstacle runAction:sequence];
                 }else{
                      [topObstacle runAction:sequence2];
                      [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
                 }
        }else if ([GameStatus sharedState].levelNumber==19)
        {
            movetoY=[SKAction moveToY:topObstacle.position.y-50 duration:0.9];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:2.3-(0.1*[GameStatus sharedState].levelNumber)];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+50 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.2];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
//            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            
            if (_debrisCount%4==0 ) {
                [topObstacle runAction:sequence2];
                [bottomObstacle runAction:sequence];

            }else{
                [bottomObstacle runAction:sequence];

                 [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
            }
        
        }else if ([GameStatus sharedState].levelNumber==20)
        {
            
            sequence1 = [SKAction sequence:@[
                                                       [SKAction moveByX:-moveX y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]]];
            
            movetoY=[SKAction moveToY:topObstacle.position.y-40 duration:0.8];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+20 duration:1.4];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+40 duration:0.8];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-20 duration:0.4];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            
            int num=arc4random()%1;
            if (num==0) {
                [topObstacle runAction:sequence2];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];

            }else if (num==1){
                [bottomObstacle runAction:sequence];
                
                [topObstacle runAction:[SKAction group:@[sequence1,repeatTop]]];
            
            }
            
        }else if ([GameStatus sharedState].levelNumber==21)
        {
            
            movetoY=[SKAction moveToY:topObstacle.position.y-40 duration:0.9];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:1.5];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+40 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.5];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            
            int num=arc4random()%1;
            if (num==0) {
                [topObstacle runAction:sequence2];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
                
            }else if (num==1){
                [bottomObstacle runAction:sequence];
                
                [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
                
            }

            
        }else if ([GameStatus sharedState].levelNumber==22)
        {
            topObstacle.position=CGPointMake(startX+85, ((_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
            if (_isImmunePowerOn) {
                topObstacle.position=CGPointMake(startX+85, ((playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
            }

            
            movetoY=[SKAction moveToY:topObstacle.position.y-20 duration:1.4];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+20 duration:1.6];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+30 duration:1.6];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.6];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
            [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
            
            int num=arc4random()%2;
            if (_debrisCount>1) {
                
            
            if (num==0) {
                [topObstacle runAction:sequence2];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
                NSLog(@"-----0------ ");
            }else if (num==1){
                [bottomObstacle runAction:sequence];
                
                [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
                 NSLog(@"-----1------ ");
            }
            else if(num==2)
            {
                [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
                 NSLog(@"-----2------ ");
            }
            
            }else{
             [topObstacle runAction:sequence2];
            [bottomObstacle runAction:sequence];
            }

        }
        
        else if ([GameStatus sharedState].levelNumber==23)
        {
            
            topObstacle.position=CGPointMake(startX+85, ((_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
            if (_isImmunePowerOn) {
                topObstacle.position=CGPointMake(startX+85, ((playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
            }

           
            movetoY=[SKAction moveToY:topObstacle.position.y-40 duration:0.9];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:1.5];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+40 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.5];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
            [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
            
            int num=arc4random()%2;
            if (num==0) {
                [topObstacle runAction:sequence2];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
                
            }else if (num==1){
                [bottomObstacle runAction:sequence];
                
                [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
                
            }
            else if(num==2)
            {
                [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
                [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
            }

            
        }
        
        else if ([GameStatus sharedState].levelNumber==24)
        {
            
            SKAction *sequence = [SKAction sequence:@[
                                                      [SKAction moveByX:-moveX-50 y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]
                                                      ]];
            SKAction *sequence1 = [SKAction sequence:@[
                                                       [SKAction moveByX:-moveX-50 y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber]]];
            SKAction *sequence2=[SKAction sequence:@[sequence1,[SKAction removeFromParent]]];
            

            
              bottomObstacle.position = CGPointMake(startX+25,ypos1+10);
            topObstacle.position=CGPointMake(startX+90, ((_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-25);
            if (_isImmunePowerOn) {
                topObstacle.position=CGPointMake(startX+90, ((playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-25);
            }
            

            movetoY=[SKAction moveToY:topObstacle.position.y-50 duration:0.9];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:1.5];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+50 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.5];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            
            [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
            [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
        }

        else if ([GameStatus sharedState].levelNumber==25)
        {
            
            SKAction *sequence = [SKAction sequence:@[
                                                      [SKAction moveByX:-moveX-50 y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber],[SKAction removeFromParent]
                                                      ]];
            SKAction *sequence1 = [SKAction sequence:@[
                                                       [SKAction moveByX:-moveX-50 y:0 duration:moveDuration-0.1*[GameStatus sharedState].levelNumber]]];
            SKAction *sequence2=[SKAction sequence:@[sequence1,[SKAction removeFromParent]]];
            
            bottomObstacle.position = CGPointMake(startX+25,ypos1+10);
            topObstacle.position=CGPointMake(startX+105, ((_player.size.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-45);
            if (_isImmunePowerOn) {
                topObstacle.position=CGPointMake(startX+105, ((playerSize.height*kGapMultiplier+bottomObstacle.size.height/h+bottomObstacle.size.height/h)+41-[GameStatus sharedState].levelNumber)-35);
            }

            movetoY=[SKAction moveToY:topObstacle.position.y-50 duration:0.9];
            movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:1.5];
            movetoYBottom=[SKAction moveToY:bottomObstacle.position.y+60 duration:1.2];
            movetoYBottomReverse=[SKAction moveToY:bottomObstacle.position.y-30 duration:1.5];
            SKAction *seqTop=[SKAction sequence:@[movetoY,movtoYReverse]];
            SKAction *seqBottom=[SKAction sequence:@[movetoYBottom,movetoYBottomReverse]];
            SKAction *repeatTop=[SKAction repeatActionForever:seqTop];
            SKAction *repeatBottom=[SKAction repeatActionForever:seqBottom];
            
            [topObstacle runAction:[SKAction group:@[sequence2,repeatTop]]];
            [bottomObstacle runAction:[SKAction group:@[sequence,repeatBottom]]];
        }


    
  }
//}
    if([GameStatus sharedState].levelNumber>25&&[GameStatus sharedState].levelNumber<=32)
    {
        _debrisCount++;
        
        float startX = self.size.width + bottomObstacle.size.width/2;

        kGroundSpeed=135.0;

        
        
        float moveX= self.size.width + bottomObstacle.size.width;

        float moveDuration = moveX / kGroundSpeed;
        
        
        float bottomObstacleMin;
        
        topObstacle.zRotation = DegreesToRadians(180);
        
        if ([UIScreen mainScreen].bounds.size.height>500) {
            
            bottomObstacleMin = (_playableStart - bottomObstacle.size.height/2+30) + _playableHeight * kBottomObstacleMinFraction+30;
            NSLog(@"bottom obstacle %f",bottomObstacleMin);
        }
        else{
            bottomObstacleMin = (_playableStart - bottomObstacle.size.height/2) + _playableHeight * kBottomObstacleMinFraction;
            
        }
        
        
        float bottomObstacleMax = (_playableStart - bottomObstacle.size.height/2) + _playableHeight * kBottomObstacleMaxFraction;
        NSLog(@"bottom obstacle max %f",bottomObstacleMax);
        bottomObstacle.position = CGPointMake(startX, RandomFloatRange(bottomObstacleMin, bottomObstacleMax)-45);
        NSLog(@"bottom obstacle max %f",bottomObstacle.position.y);
        
        if ([UIScreen mainScreen].bounds.size.height>500) {
            
          topObstacle.position = CGPointMake(startX, (bottomObstacle.position.y + bottomObstacle.size.height/2 + _player.size.height * kGapMultiplier)-90);
            if (_isImmunePowerOn) {
                 topObstacle.position = CGPointMake(startX, (bottomObstacle.position.y + bottomObstacle.size.height/2 + playerSize.height * kGapMultiplier)-90);
            }
        }
        else{
            
          topObstacle.position = CGPointMake(startX,( bottomObstacle.position.y + bottomObstacle.size.height + _player.size.height * kGapMultiplier));
            
            if (_isImmunePowerOn) {
                topObstacle.position = CGPointMake(startX, (bottomObstacle.position.y + bottomObstacle.size.height/2 + playerSize.height * kGapMultiplier));
            }
            NSLog(@"topostacle position %f",topObstacle.position.y);
        }

        
        SKAction *sequence = [SKAction sequence:@[
                                        [SKAction moveByX:-moveX-50 y:0 duration:moveDuration],[SKAction removeFromParent],
                                                  ]];

       SKAction *movetoY=[SKAction moveToY:topObstacle.position.y-30 duration:0.5];
       SKAction *movtoYReverse=[SKAction moveToY:topObstacle.position.y+30 duration:0.5];
        SKAction *bottomovetoY=[SKAction moveToY:bottomObstacle.position.y-30 duration:0.5];
        SKAction *bottomovtoYReverse=[SKAction moveToY:bottomObstacle.position.y+30 duration:0.5];

        SKAction *seq=[SKAction sequence:@[movetoY,movtoYReverse]];
         SKAction *seq2=[SKAction sequence:@[bottomovetoY,bottomovtoYReverse]];
       
        SKAction *repeat=[SKAction repeatActionForever:seq];
         SKAction *repeat2=[SKAction repeatActionForever:seq2];
        
       SKAction *group=[SKAction group:@[repeat, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
        SKAction *group2=[SKAction group:@[repeat2, [SKAction moveByX:-moveX y:0 duration:moveDuration]]];
      SKAction *sequencetop = [SKAction sequence:@[group,[SKAction removeFromParent]]];
      SKAction *sequenceBottom = [SKAction sequence:@[group2,[SKAction removeFromParent]]];
        
        if (_debrisCount%4==0) {
        topObstacle.position=CGPointMake(topObstacle.position.x, topObstacle.position.y+20);
        bottomObstacle.position=CGPointMake(bottomObstacle.position.x, bottomObstacle.position.y-15);
            if (_debrisCount==8||_debrisCount==16||_debrisCount==24) {
                [topObstacle runAction:sequencetop];
                [bottomObstacle runAction:sequenceBottom];
            }else{
                [topObstacle runAction:sequence];
                [bottomObstacle runAction:sequence];

            }
            
         }else{
            
         [topObstacle runAction:sequencetop];
         [bottomObstacle runAction:sequenceBottom];
         
         }

    
    }
}



-(void)flapPlayer{
 

    if (_player.position.y>=self.size.height-20) {
        _playerVelocity = CGPointMake(0, 15);
        // Move sombrero
        SKAction *moveUp = [SKAction moveByX:0 y:0 duration:0.1];
        moveUp.timingMode = SKActionTimingEaseInEaseOut;
        SKAction *moveDown = [moveUp reversedAction];
        [_sombrero runAction:[SKAction sequence:@[moveUp, moveDown]]];
    }else{
  _playerVelocity = CGPointMake(0, kImpulse);
    // Move sombrero
    SKAction *moveUp = [SKAction moveByX:0 y:12 duration:0.1];
    moveUp.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *moveDown = [moveUp reversedAction];
    [_sombrero runAction:[SKAction sequence:@[moveUp, moveDown]]];
    }
  
}


-(void)call{
    _score=(int)[GameStatus sharedState].remScore;

    self.pauseButton.hidden=NO;
    self.state=NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

}
#pragma mark----------------touch begin

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
   SKSpriteNode *sp=(SKSpriteNode *)node;
//    [node.name isEqualToString:@"music"]||

    if ([node.name isEqualToString:@"music"]||(self.musicButton.position.x==touchLocation.x&&self.musicButton.position.y==touchLocation.y)){
        NSLog(@"music button is tapped");
        [self musicButtonToggle:sp];
              return;
    }

    if ([node.name isEqualToString:@"pause"]||(self.pauseButton.position.x==touchLocation.x&&self.pauseButton.position.y==touchLocation.y)){
        
        [self pauseButtonClick];
        return;
    }
   
    
    if (self.state==YES) {
     [self call];
    }
    
       switch (_gameState) {
        case GameStateMainMenu:
            break;
        case GameStateTutorial:
            [self switchToPlay];
            break;
        case GameStatePlay:
            [self flapPlayer];
            break;
        case GameStateFalling:
            break;
        case GamestatePause:
               break;
        case GameStateShowingScore:
            break;
        case GameStateGameOver:
            break;
    }
    
       }

#pragma mark - Switch state

- (void)switchToFalling {
  _gameState = GameStateFalling;  
      if (self.num==1) {
    [self runAction:[SKAction sequence:@[
                                         _fallingAction]]];
      }

}

- (void)switchToShowScore :(int)retryOrNext{

       [[NSNotificationCenter defaultCenter] postNotificationName:@"adMobBanner" object:nil];

     NSLog(@"switch to score");

    if (self.num==1) {
         [self runAction:_popAction];
    }
    [GameStatus sharedState].remScore=0;
    [GameStatus sharedState].remTime=30;
    
    [self setBestScore:_score];
    
    [self.timer invalidate];
    self.timer=nil;

    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
        
    }
    [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"scoreINlevel"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"score saved %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]);
    
  
    [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"scoreINlevel"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    self.layerHudNode=nil;
    self.pauseButton=nil;
    self.time=nil;
//    self.resumeLabel=nil;
    self.Level=nil;
    self.musicButton=nil;
    self.texure1=nil;
    self.texure2=nil;
    self.resumeView=nil;
//    self.resumeLabel=nil;
    self.lifeLabel=nil;
    _scoreLabel=nil;
    _parallaxNodeBackgrounds=nil;
    [_coins removeAllObjects];
    [coinMinus removeAllObjects];
    _coins=nil;
    coinMinus=nil;
    [self removeAllActions];
     [GameStatus sharedState].isGamePlaying=NO;
//    [self removeAllChildren];
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionLeft duration:3.0];
    GameOverScene *newScene =[[GameOverScene alloc] initWithSize:self.size
                                                retryOrNextLevel:retryOrNext  playSound:self.num]   ;
   
    newScene.bestScore=[NSString stringWithFormat:@"%d",[self bestScore]];
    [self.scene.view presentScene: newScene transition: reveal];

}

- (void)switchToNewGame {
    
    [self runAction:_popAction];
    [self removeAllActions];
    [self removeAllChildren];
    [self.timer invalidate];
    self.timer=nil;
    _gameState=GameStateGameOver;
    

    [GameStatus sharedState].remScore=_score;
    [GameStatus sharedState].remTime=self.timeSec;
    [_musicPlayer stop];
    _musicPlayer=nil;
    self.layerHudNode=nil;
    self.pauseButton=nil;
    self.time=nil;
    //    self.resumeLabel=nil;
    self.Level=nil;
    self.musicButton=nil;
    self.texure1=nil;
    self.texure2=nil;
    self.resumeView=nil;
    //    self.resumeLabel=nil;
    self.lifeLabel=nil;
    _scoreLabel=nil;
    _parallaxNodeBackgrounds=nil;
    [_coins removeAllObjects];
    [coinMinus removeAllObjects];
    _coins=nil;
    coinMinus=nil;
    
    SKScene *newScene = [[MyScene alloc] initWithSize:self.size ];
    SKTransition *transition = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.5];
    [self.view presentScene:newScene transition:transition];
    
}

- (void)switchToGameOver {
  _gameState = GameStateGameOver;
}

- (void)switchToTutorial {

  _gameState = GameStateTutorial;
  [self setupBackground];
  //[self setupForeground];
  [self setupPlayer];
  [self setupSounds];
  [self setupSombrero];
  [self setupScoreLabel];
  [self setupTutorial];

}

- (void)switchToPlay {

  // Set state
  _gameState = GameStatePlay;

  [_worldNode enumerateChildNodesWithName:@"Tutorial" usingBlock:^(SKNode *node, BOOL *stop) {
//      NSLog(@"childNode ");
    [node runAction:[SKAction sequence:@[
      [SKAction fadeOutWithDuration:0.5],
      [SKAction removeFromParent]
    ]]];
  }];
  
  // Remove wobble
  [_player removeActionForKey:@"Wobble"];
  
    

  // Start spawning
  [self startSpawning];
    float imunePower =[self randomValueBetween:1 andValue:17];
   
 [self flapPlayer];
    [self performSelector:@selector(startImunePower) withObject:self afterDelay:imunePower];
  // Move player
 }
#pragma mark - Immune Power

-(void)startImunePower{
    
    _immunPowerNode = [SKSpriteNode spriteNodeWithImageNamed:@"superpower.png"];
    
    _immunPowerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:35.0];
    
    _immunPowerNode.physicsBody.categoryBitMask=EntityCategoryImunePower;
    _immunPowerNode.physicsBody.collisionBitMask=0;
    _immunPowerNode.physicsBody.contactTestBitMask=EntityCategoryPlayer;
    _immunPowerNode.zPosition=10;
    _immunPowerNode.position=CGPointMake(290, 160);
    [_immunPowerNode setXScale:0.5];
    [_immunPowerNode setYScale:0.5];
    [self addChild:_immunPowerNode];

    CGPoint location = CGPointMake(-320, self.frame.size.width/2+100);
    SKAction *moveAction = [SKAction moveTo:location duration:5.20];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"Animation Completed");
        _immunPowerNode.hidden = YES;
    }];
    
    SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [_immunPowerNode runAction:moveAsteroidActionWithDone withKey:@"PowerMoving"];

    
}


#pragma mark - Updates

- (void)checkHitGround {
    if (_gameState==GameStateGameOver) {
        return;
    }
      if (_hitGround) {//if2
      _hitGround = NO;
          _gameState=GameStateGameOver;
          [GameStatus sharedState].remLife=[GameStatus sharedState].remLife-1;
       [[NSUserDefaults standardUserDefaults]setInteger:[GameStatus sharedState].remLife forKey:@"life" ];
          self.lifeLabel.text=[NSString stringWithFormat:@"Life %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"life"]];

    [[NSUserDefaults standardUserDefaults] synchronize];
        _playerVelocity = CGPointZero;
        _player.position = CGPointMake(_player.position.x, _playableStart + _player.size.width/2);
        _player.zRotation = DegreesToRadians(-90);
        
     if (self.num==1) {
         [self runAction:_hitGroundAction];
      }
       
     if (_musicPlayer) {
              [_musicPlayer stop];
              _musicPlayer=nil;
              
      }

          NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
     if ([userDefault integerForKey:@"life"]==0 ){
            NSDate* now = [NSDate date];
            NSDateFormatter *formate = [[NSDateFormatter alloc] init];
            [formate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
            NSString *dateStr = [formate stringFromDate:now];
            [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"strtdate"];
            [[NSUserDefaults standardUserDefaults]synchronize];

            [self switchToShowScore:1];
            
        }//if3
      else{//else3
         
              [self switchToShowScore:1];
       
       }//else3

        
    }//if2
    
}

- (void)checkHitObstacle {
    
    
    if (_hitObstacle) {
        _hitObstacle = NO;
        [self switchToFalling];
        
    }

 }

- (void)updatePlayer {
  
    if (self.isPause==YES) {
        return;
    }
  // Apply gravity
  CGPoint gravity = CGPointMake(0, kGravity);
  CGPoint gravityStep = CGPointMultiplyScalar(gravity, _dt);
  _playerVelocity = CGPointAdd(_playerVelocity, gravityStep);

  // Apply velocity
  CGPoint velocityStep = CGPointMultiplyScalar(_playerVelocity, _dt);
    _player.position = CGPointAdd(_player.position, velocityStep);
    

  // Temporary halt when hits ground
  if ((_player.position.y - _player.size.height/2 <= _playableStart-40) || (_player.position.y > 670.0)) {

      _playerVelocity = CGPointZero;
     
      _player.position = CGPointMake(_player.position.x, _playableStart + _player.size.width/2);
      _player.zRotation = DegreesToRadians(-180);

      _player.hidden=YES;
      
      if (_isImmunePowerOn==YES) {
          [self.timer invalidate];
          self.timer=nil;
//          CGPoint lowerLeft = CGPointMake(0, _playableStart);
          CGPoint lowerRight = CGPointMake(self.size.width, _playableStart);
          _player.position=CGPointMake(lowerRight.x, lowerRight.y);
              if (self.num==1) {
            [self runAction:_hitGroundAction];
              }
      }
//    [_player removeFromParent];
      [_musicPlayer stop];
      
  }
}

- (void)updateForeground {

  [_worldNode enumerateChildNodesWithName:@"Foreground" usingBlock:^(SKNode *node, BOOL *stop) {
    SKSpriteNode *foreground = (SKSpriteNode *)node;
    CGPoint moveAmt = CGPointMake(-kGroundSpeed * _dt, 0);
    foreground.position = CGPointAdd(foreground.position, moveAmt);
    
    if (foreground.position.x < -foreground.size.width) {
      foreground.position = CGPointAdd(foreground.position, CGPointMake(foreground.size.width * kNumForegrounds, 0));
    }
    
  }];

}

-(void)updateScore {
    
 [_worldNode enumerateChildNodesWithName:@"BottomObstacle" usingBlock:^(SKNode *node, BOOL *stop) {
      SKSpriteNode *obstacle = (SKSpriteNode *)node;
    
      NSNumber *passed = obstacle.userData[@"Passed"];
      if (passed && passed.boolValue) return;
     
         if (_gameState==GameStateGameOver) {
             return;
         }
         _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];

      if (self.obstacleCross==YES && _hitObstacle == NO) {
            
      if (_player.position.x > obstacle.position.x + obstacle.size.width/2 ) {
//          val=val + 1;
         _score++;
          
          self.obstacleCross=NO;
        _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
            if (self.num==1) {
        [self runAction:_coinAction];
            }
        obstacle.userData[@"Passed"] = @YES;
      }
    }
  }];
}

-(void)update:(CFTimeInterval)currentTime {
//    NSLog(@"in update method");
    
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;

    switch (_gameState) {
        case GameStateMainMenu:
            break;
        case GameStateTutorial:
            break;
        case GameStatePlay:
       
            [self checkHitGround];
            [self checkHitObstacle];
            [self updateForeground];
            [self updatePlayer];
            [self updateScore];
            break;
        case GameStateFalling:
           
            [self checkHitGround];
            [self updatePlayer];
            break;
        case GameStateShowingScore:
            break;
        case GameStateGameOver:
            break;
        case GamestatePause:
            break;
    }
    
    [_parallaxNodeBackgrounds update:currentTime];
    
    if ( _gameState == GameStatePlay) {
        
        //Astroid action Commiting 28 june by me
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        float randSecs=[self randomValueBetween:2.0 -.01*[GameStatus sharedState].levelNumber andValue:10.0];
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
                //NSLog(@"Animation Completed");
            asteroid.hidden = YES;
                    }];
        
        SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
        
        [asteroid runAction:moveAsteroidActionWithDone withKey:@"asteroidMoving"];
        
        double curTime = CACurrentMediaTime();
        if (self.pauseOrResume==1) {
            
        if (curTime > _nextCoinSpawn) {
            _nextAsteroidSpawn = randSecs + curTime;
            
            float randY = [self randomValueBetween:0.0 andValue:self.frame.size.height];
            float randDuration = [self randomValueBetween:0.0 andValue:10.0];
            
            SKSpriteNode *coin= [_coins objectAtIndex:_nextCoin];
            _nextCoin++;
            
            if (_nextCoin >= _coins.count) {
                _nextCoin = 0;
            }
            
            [coin removeAllActions];
            coin.position = CGPointMake(self.frame.size.width+asteroid.size.width/2, randY);
            coin.hidden = NO;
            
            CGPoint location = CGPointMake(-self.frame.size.width-coin.size.width, randY);
            
            SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
            SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
                    //NSLog(@"Animation Completed");
                coin.hidden = YES;
            }];
            
      
            
         SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
            
            [coin runAction:moveAsteroidActionWithDone withKey:@"coinMoving"];

            
        }
         #pragma coinMinus
            
            double curTime = CACurrentMediaTime();
            if (curTime > _nextCoinMinusSpawn) {
                _nextCoinMinusSpawn = randSecs + curTime;
                
             float randY = [self randomValueBetween:0.0 andValue:self.frame.size.height];
               float randDuration = [self randomValueBetween:0.0 andValue:10.0];
                
                SKSpriteNode *coinM= [coinMinus objectAtIndex:_nextCoinMinus];
                _nextCoinMinus++;
                
                if (_nextCoinMinus >= coinMinus.count) {
                    _nextCoinMinus = 0;
                }
                
                [coinM removeAllActions];
                coinM.position = CGPointMake(self.frame.size.width+asteroid.size.width/2, randY);
                coinM.hidden = NO;
                
                CGPoint location = CGPointMake(-self.frame.size.width-coinM.size.width, randY);
                
                SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
                SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
                        //NSLog(@"Animation Completed");
                    coinM.hidden = YES;
                }];
                
                SKAction *moveAsteroidActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
                
                [coinM runAction:moveAsteroidActionWithDone withKey:@"coinMinusMoving"];
                
           }
        }
    
    }}
}





#pragma mark - comets random method

- (float)randomValueBetween:(float)low andValue:(float)high {
    
    
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

#pragma mark - Special

- (void)shareScore {
}

#pragma mark - Score
- (int)bestScore {
  return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
}

- (void)setBestScore:(int)bestScore {
    if (_score>[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"BestScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

#pragma mark - Collision Detection


- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if(_gameState == GameStateGameOver){
        return;
    }
    
    SKPhysicsBody *other = (contact.bodyA.categoryBitMask == EntityCategoryPlayer ? contact.bodyB : contact.bodyA);
    
    if (other.categoryBitMask == EntityCategoryGround) {//if2
        NSLog( @"hit ground method");
            _player.hidden=YES;
        
            [self popForlife];
        [[NSNotificationCenter defaultCenter]removeObserver:self
     name:@"LifeAdded" object:nil];
    
        [self.timer invalidate];
        self.timer=nil;
        
        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSLog(@"hit  ground  yes..................... ");

                self.isPause = YES;
                self.pauseOrResume=2;
                self.scene.paused=YES;
                timerStop=1;

                
                BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
                

                if (connection==YES) {
                    if (self.num==1) {
                [self runAction:[SKAction sequence:@[
                                                             _fallingAction]]];
                    }
                    [self createUI:@""];
                    [UIView animateWithDuration:.3 animations:^{
                        self.containerView.frame = CGRectMake(30, 105, 250, 298);
                    }];

                  }
                else{
                    if (self.num==1) {
                        [self runAction:[SKAction sequence:@[
                                                             _fallingAction]]];
                    }

                    _hitGround = YES;
                    _hitObstacle = YES;
                    self.isPause=NO;
                    self.scene.paused=NO;
                    
                    NSDate* now = [NSDate date];
                    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
                    [formate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    NSString *dateStr = [formate stringFromDate:now];
                    [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"strtdate"];
                    [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"firedate"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LifeAdded" object:nil];
                }
    }
    
    if (other.categoryBitMask == EntityCategoryObstacle) {
        
        
        if (_isImmunePowerOn==YES && _hitObstacle==NO && _hitGround==NO) {
            NSLog(@"in first if loop");
            
            return;
        }
        else{
       
            timerStop=1;
        [self addExplosion:_player.position withName:@"LifeBarExplosion"];
        [self addExplosion:_player.position withName:@"HaloExplosion"];
            
         _hitObstacle = YES;
            
            NSLog(@"power second %ld",(long)_imunePowerSec);
            NSLog(@"Hit Obstacle 1");
            
            return;
        }
        
    }
    
    if (other.categoryBitMask==EntityCategoryCoin) {
        
        NSLog(@"+ coin collision");
        _score=_score+10;
            if (self.num==1) {
             [self runAction:_coinAction];
        }
        if (contact.bodyA.categoryBitMask == EntityCategoryPlayer) {
            SKNode *enemy =contact.bodyB.node ;
            [enemy removeFromParent];
        }
        else{
            SKNode *enemy =contact.bodyA.node ;
            [enemy removeFromParent];
        }
        
        _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
        NSLog(@"score ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        return;
    }
    if (other.categoryBitMask==EntityCategoryCoinMinus) {
         NSLog(@"+ coin collision");
        _score=_score+10;
        if (self.num==1) {
            [self runAction:_coinAction];
        }

        if (contact.bodyA.categoryBitMask == EntityCategoryPlayer) {
            SKNode *enemy =contact.bodyB.node ;
            [enemy removeFromParent];
        }
        else{
            
            SKNode *enemy =contact.bodyA.node ;
            [enemy removeFromParent];
        }
        
        _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
        NSLog(@"score ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        
        return;

    }
    if (other.categoryBitMask==EntityCategoryImunePower) {
        
        if (contact.bodyA.categoryBitMask == EntityCategoryPlayer) {
            NSLog(@"immune power on");
            if (_hitObstacle == NO) {

            SKNode *enemy =contact.bodyB.node ;
            [enemy removeFromParent];
            if (self.num==1) {
                [self runAction:_powerAction];
            }
            _isImmunePowerOn=YES;
            NSMutableArray *blueFrames = [NSMutableArray array];
     SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"SuperPower"];

            for (int i=0; i <= 3; i++) {
                NSString *textureName = [NSString stringWithFormat:@"sp_%d.png", i];
                SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
                [blueFrames addObject:temp];
            }
            powerBlueFrames= blueFrames;
              NSMutableArray *redFrames = [NSMutableArray array];
            for (int i=4; i <= 7; i++) {
                NSString *textureName = [NSString stringWithFormat:@"sp_%d.png", i];
                SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
                [redFrames addObject:temp];
            }
            powerRedFrames=redFrames;
                NSMutableArray *normalFrames = [NSMutableArray array];
                for (int i=1; i<=3; i++) {
                    NSString *textureName = [NSString stringWithFormat:@"Astronaut%d.png", i];
                    SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
                    [normalFrames addObject:temp];

                }
                simplePlayerFrames=normalFrames;
            
            
            [_player runAction:[SKAction repeatActionForever:
                              [SKAction animateWithTextures:powerBlueFrames
                                               timePerFrame:0.2f
                                                     resize:YES
                                                    restore:YES]] withKey:@"movingBluePlyer"];
            }
       }
    }
  }

-(void)dealloc{
    
    
}



//Adding new in 11 july

#pragma mark - pause button Method
-(void)pauseButtonClick{
  /*
    if (self.isPause == NO) {
        self.isPause = YES;
        self.pauseOrResume=2;
        self.scene.paused=YES;

    }
    else{
        self.isPause = NO;
        self.pauseOrResume=1;
        self.scene.paused=NO;

    }
   */
    self.isPause = YES;
    self.pauseOrResume=2;
    self.scene.paused=YES;
    if (timerStop==1) {
        return;
    }
    if (!self.resumeView) {
      
      self.resumeView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
         [rootViewController.view addSubview:self.resumeView];
        
        
        if([UIScreen mainScreen].bounds.size.height>500){
            
            if ([GameStatus sharedState].levelNumber<=10) {
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg1.png"]];

            }else if ([GameStatus sharedState].levelNumber>10&&[GameStatus sharedState].levelNumber<=20){
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_2_568.png"]];

            }else if([GameStatus sharedState].levelNumber>20&&[GameStatus sharedState].levelNumber<=30){
                  self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_4_568.png"]];
                            }
            else if ([GameStatus sharedState].levelNumber>30&&[GameStatus sharedState].levelNumber<=40){
                
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_3_568.png"]];
                
            }
        }
        else{
            if ([GameStatus sharedState].levelNumber<=10) {
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg.png"]];

            }else if ([GameStatus sharedState].levelNumber>10&&[GameStatus sharedState].levelNumber<=20){
            
                
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_2_480.png"]];

            }else if([GameStatus sharedState].levelNumber>20&&[GameStatus sharedState].levelNumber<=30){
              
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_4_480.png"]];

            }
            else if ([GameStatus sharedState].levelNumber>30&&[GameStatus sharedState].levelNumber<=40){
                self.resumeView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg_3_480.png"]];
                
            }
            
        }

    
       
        UIButton *menuButton=[UIButton buttonWithType:UIButtonTypeCustom];
      [menuButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
      menuButton.frame=CGRectMake(110, self.view.frame.size.height-350, 100, 100);
      [menuButton addTarget:self action:@selector(menuButtonClick) forControlEvents:UIControlEventTouchUpInside];
      [self.resumeView addSubview:menuButton];
    
      
      UIButton *resumeButton=[UIButton buttonWithType:UIButtonTypeCustom];
      [resumeButton setImage:[UIImage imageNamed:@"resume.png"] forState:UIControlStateNormal];
    
      [resumeButton addTarget:self action:@selector(resumeButtonClick) forControlEvents:UIControlEventTouchUpInside];
     [self.resumeView addSubview:resumeButton];
   
    if([UIScreen mainScreen].bounds.size.height>500){
        resumeButton.frame=CGRectMake(110, 280, 100, 100);
        menuButton.frame=CGRectMake(110, self.view.frame.size.height-350-30, 100, 100);
        
    }else{
    resumeButton.frame=CGRectMake(110, 250, 100, 100);
     menuButton.frame=CGRectMake(110, self.view.frame.size.height-350, 100, 100);
    }
    
    [self runSpinAnimationOnView:menuButton duration:1.0 rotations:1.0 repeat:0];
    [self runSpinAnimationOnView:resumeButton duration:1.0 rotations:1.0 repeat:0];
    
    
    NSArray *images = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"star1.png"],
                       [UIImage imageNamed:@"star2.png"],
                       [UIImage imageNamed:@"star3.png"],
                       
                       nil];
    
    
    UIImageView * imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"asteroid.png"]];
        //snack.frame = CGRectMake(104, 76, 32, 22);
    imageView1.frame = CGRectMake(10,50 , 80, 80);
    [self.resumeView addSubview:imageView1];
   
    UIImageView * imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"asteroid.png"]];
        //snack.frame = CGRectMake(104, 76, 32, 22);
    imageView2.frame = CGRectMake(100,150 , 80, 80);
    [self.resumeView addSubview:imageView2];
   
    
    
    for (int i=0; i<=25; ++i) {
        
      UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star1.png"]];
            //snack.frame = CGRectMake(104, 76, 32, 22);
        imageView.frame = CGRectMake(arc4random()%320, arc4random()%480, 32, 22);
        imageView.animationImages = images;
                imageView.animationDuration = 1;
                imageView.animationRepeatCount = 0; // 0 = nonStop repeat
                [imageView startAnimating];
           [self.resumeView addSubview:imageView];
        
        CABasicAnimation *hover = [CABasicAnimation animationWithKeyPath:@"position"];
        hover.additive = YES; // fromValue and toValue will be relative instead of absolute values
        hover.fromValue = [NSValue valueWithCGPoint:CGPointZero];
        hover.toValue = [NSValue valueWithCGPoint:CGPointMake(180.0, 420.0)]; // y increases downwards on iOS
        hover.autoreverses = YES; // Animate back to normal afterwards
        hover.duration = 10; // The duration for one part of the animation (0.2 up and 0.2 down)
        hover.repeatCount = INFINITY; // The number of times the animation should repeat
        [imageView1.layer addAnimation:hover forKey:@"myHoverAnimation"];
        [imageView2.layer addAnimation:hover forKey:@"myHoverAnimation"];
    }
    
    }
    
    else{
        self.resumeView.hidden=NO;
     NSLog(@"resume hidden no");
    }
      [self.timer invalidate];
    self.timer=nil;
          self.timeSecCount=2;
    self.timeSecCount=self.timeSec;
    
 }


- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


-(void)resumeButtonClick{
    kGravity=-1500;
        //[self setupPlayer];
//     [self.resumeView removeFromSuperview];
    self.resumeView.hidden=YES;
 
    self.isPause = NO;
    self.pauseOrResume=1;
    self.timeSec=self.timeSecCount;
    [self call];
    self.scene.paused=NO;
    return;

}

-(void)resumeBack
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resumeTimer) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer1 forMode:NSDefaultRunLoopMode];
}


-(void)resumeTimer
{
     [self.resumeView removeFromSuperview];
    if (self.timeSecCount>0) {
        self.timeSecCount--;
        [self.scene setUserInteractionEnabled:NO];
}
    
    if (self.timeSecCount==0) {
        [self.timer1 invalidate];
        self.timer1=nil;
        self.scene.paused=NO;
        
        [self.scene setUserInteractionEnabled:YES];

        kGravity=-1500;
        
        [self call];
        _gameState=GameStatePlay ;
       
        self.pauseOrResume=1;
        self.isPause = NO;
    }
}


#pragma mark -
#pragma mark - Menu Button Method

-(void)menuButtonClick{
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
        
    }
//    self.button.hidden=YES;
    
  
    
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    int life = (int)[userDefault integerForKey:@"life"];
//    life--;
//    if (life<0) {
//        life = 0;
//    }
//    [userDefault setInteger:life forKey:@"life"];
//    [userDefault synchronize];
    
    [self.resumeView removeFromSuperview];
    GameStartScreen *gameStart=[[GameStartScreen alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
    [self.scene.view presentScene:gameStart];
}


#pragma mark -
#pragma mark - Space Dust
    //Smoke Animation
- (void)configureEmitters {
    
        //Use the same .sks file for both left and right trails
    bodyEmitterLeft = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SpaceDustTrails" ofType:@"sks"]];

    
    bodyEmitterLeft.position = CGPointMake(-27, -8);
    bodyEmitterLeft.name = @"spaceDustTrails";
    bodyEmitterLeft.zPosition = 0;
    [_player addChild:bodyEmitterLeft];
    
    
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


- (void)setupHUD {
    
        //Add HUD
    _layerHudNode = [SKNode new];
    
        //setup HUD basics
    /*
        //Position the life hearts
           _heartFullTexture = [SKTexture textureWithImageNamed:@"life4.png"];
   
    int offset = 0;
    for(int i = 1; i <=[[NSUserDefaults standardUserDefaults]integerForKey:@"life" ] ; i++) {
        SKSpriteNode *heart = [SKSpriteNode spriteNodeWithTexture:_heartFullTexture];
        heart.name = [NSString stringWithFormat:@"health%d", i];

        
        if([UIScreen mainScreen].bounds.size.height>500){
            heart.position = CGPointMake(self.size.width - (heart.frame.size.width  + offset),
                                         self.size.height - heart.frame.size.height + 2-10);
        }
        else{
            
            heart.position = CGPointMake(self.size.width - (heart.frame.size.width -6 + offset),
                                         self.size.height - heart.frame.size.height + 2-10);
             }
 
        [self addChild:heart];
        offset += 23;
        
    }
    [self addChild:_layerHudNode];*/
    
    
    
    self.lifeLabel = [[SKLabelNode alloc] init];
    self.lifeLabel.fontColor = [UIColor whiteColor];
    self.lifeLabel.fontSize=30.0;
    self.lifeLabel.fontName=@"Transformers Movie";
    NSString *lifeValue = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults]integerForKey:@"life"]];
    self.lifeLabel.text=[NSString stringWithFormat:@"Life %@",lifeValue];
     [self addChild:self.lifeLabel];
    if ([UIScreen mainScreen].bounds.size.height>500) {
        
        self.lifeLabel.position = CGPointMake(260, 520);
    }
    else{
        self.lifeLabel.position = CGPointMake(260, 440);
    }

}


@end
