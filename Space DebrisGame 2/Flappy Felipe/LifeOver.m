//
//  LifeOver.m
//  Space Debris
//
//  Created by Globussoft 1 on 7/16/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "LifeOver.h"
#import "AppStore.h"
#import "LevelSelectionScene.h"
#import <Chartboost/Chartboost.h>
#import "GameStartScreen.h"
#import "AppDelegate.h"
#import "SBJson.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GAIDictionaryBuilder.h"
#import "GAI.h"

#define RequestTOFacebook @"LifeRequest"


@implementation LifeOver
//static NSString *const kFontName = @"PressStart2P";
static NSString *const kFontName1 = @"NKOTB Fever";

+(SKScene *) scene
{
        // 'scene' is an autorelease object.
	SKScene *scene = [SKScene node];
	
        // 'layer' is an autorelease object.
	LifeOver *lifeOver = [LifeOver node];
	
        // add layer as a child to scene
	[scene addChild: lifeOver];
	
        // return the scene
	return scene;
}

-(id)initWithSize:(CGSize)size{

    
    if (self = [super initWithSize:size]) {
        rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];

        BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
        if (connection) {
//            Live
//            [Chartboost startWithAppId:@"54855fbe04b01619967e2159"
//                appSignature:@"6aea83bfc107bd7f6135bdf58b4165e218aaea0a"      delegate:self];
            
//            Testing
            [Chartboost startWithAppId:@"54ef306204b01656bb289a4c"
                appSignature:@"47e70e91d2d86e1acb374add7cba77b532d18ad1"      delegate:self];
        }

        isSuccess=0;
        isInterstitialFail=YES;
        
          BOOL networkConnection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable" ];
        if (networkConnection) {
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTimeNotification:) name:@"CheckTimeForLife" object:nil];
        
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:@"DidEnterBackground" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestSuccess) name:@"postSuccess" object:nil];
        
        
        userDefault = [NSUserDefaults standardUserDefaults];
    
        SKSpriteNode *background;
        if([UIScreen mainScreen].bounds.size.height>500)
        {
            background =[[SKSpriteNode alloc] initWithImageNamed:@"blankbg1.png"];
        }
        else
        {
            background =[[SKSpriteNode alloc] initWithImageNamed:@"blankbg.png"];
        }
    background.anchorPoint = CGPointMake(0.5, 1);
    background.position = CGPointMake(self.size.width/2, self.size.height);
    [self addChild:background];

        
    SKSpriteNode *noMoreLiveButton=[[SKSpriteNode alloc] initWithImageNamed:@"nomorelife.png"];
        noMoreLiveButton.name=@"noMoreLive";
        SKAction * run5;
        if([UIScreen mainScreen].bounds.size.height>500){
         noMoreLiveButton.position=CGPointMake(150, self.size.height);
            run5=[SKAction moveToY:420 duration:0.5];
        }else{
         noMoreLiveButton.position=CGPointMake(150, self.size.height);
             run5=[SKAction moveToY:380 duration:0.5];
        }
        
  SKAction *scaleDown = [SKAction scaleTo:0.9 duration:0.75];
  SKAction *scaleUp= [SKAction scaleTo:1.0 duration:0.75];
  SKAction *fullScale = [SKAction repeatActionForever:[SKAction sequence:@[scaleDown, scaleUp, scaleDown, scaleUp]]];
  [noMoreLiveButton runAction: run5];
//                noMoreLiveButton.zRotation=10.0;
        noMoreLiveButton.zPosition=50.0;

    [self addChild:noMoreLiveButton];


    SKSpriteNode *askFriendButton=[[SKSpriteNode alloc] initWithImageNamed:@"refill_lives.png"];
       
        if([UIScreen mainScreen].bounds.size.height>500){
            askFriendButton.position=CGPointMake(320, 185);
        }else{
            askFriendButton.position=CGPointMake(320, 165);
            
        }

        SKAction * run3=[SKAction moveToX:150 duration:0.4];
      
    [askFriendButton runAction:  [SKAction sequence:@[run3,fullScale]]];
            //        noMoreLiveButton.zRotation=10.0;
    
    askFriendButton.name=@"askFriendButton";
        askFriendButton.zPosition=50.0;
    [self addChild:askFriendButton];
        

        
        SKSpriteNode *dontWait=[[SKSpriteNode alloc] initWithImageNamed:@"dont_wait.png"];
        if([UIScreen mainScreen].bounds.size.height>500){
            dontWait.position=CGPointMake(150, 235);
        }else{
            dontWait.position=CGPointMake(150, 215);
        }
        dontWait.name=@"dontWait";
        [self addChild:dontWait];

        
        
       SKSpriteNode *moreLives=[[SKSpriteNode alloc] initWithImageNamed:@"get_more_lives.png"];
        
        if([UIScreen mainScreen].bounds.size.height>500){
            moreLives.position=CGPointMake(0, 120);
        }else{
            moreLives.position=CGPointMake(0, 90);
        }
        
        
        SKAction * run4=[SKAction moveToX:150 duration:0.4];
       [moreLives  runAction:[SKAction sequence:@[run4,fullScale]]];
        moreLives.name=@"moreLivesButton";
        moreLives.zPosition=50.0;
        [self addChild:moreLives];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"runThroughlifeOver" forKey:@"checkForRunning" ];
        [[NSUserDefaults standardUserDefaults]synchronize];

        
        self.backButton=[[SKSpriteNode alloc]initWithImageNamed:@"back.png"];
        self.backButton.position=CGPointMake(50, self.size.height-40);
        self.backButton.name=@"Back";
        self.backButton.zPosition=70;
        [self addChild:self.backButton];
        
            [self compareDate];
        

       self.timeLabel=[[SKSpriteNode alloc]initWithImageNamed:@"nextlife.png"];
        if([UIScreen mainScreen].bounds.size.height>500){
         self.timeLabel.position=CGPointMake(150, 350);
        }else{
         self.timeLabel.position=CGPointMake(150, 320);
        }
       
        self.timeLabel.zPosition=20;
        [self addChild:self.timeLabel];
        
        timeLeftLabel=[[SKLabelNode alloc]initWithFontNamed:@"PressStart2P"];
        timeLeftLabel.fontColor=[UIColor colorWithRed:233.0f/255.0f
                                                green:48.0f/255.0f
                                                 blue:4.0f/255.0f
                                                alpha:1.0f];
        timeLeftLabel.fontSize=20.0;
        if([UIScreen mainScreen].bounds.size.height>500){
            timeLeftLabel.position=CGPointMake(150,305);
        }else{
            
         timeLeftLabel.position=CGPointMake(150,280);
        }
      
        timeLeftLabel.zPosition=20;

        timeLeftLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        [self addChild:timeLeftLabel];
        
        [self setupSpaceSceneLayers ];
        
    }
    return  self;
}

#pragma mark -
-(void) checkReceivedNotification:(NSNotification *)notifocation{
        // NSLog(@"notification received");
}
-(void) calculateTime{
    
 }

-(void)requestSuccess{
    alertLevel=[SKSpriteNode spriteNodeWithImageNamed:@"life_added.png"];
    alertLevel.position=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:alertLevel];
    alertLevel.zPosition=100;
    isSuccess=1;
    SKSpriteNode *cancel=[SKSpriteNode spriteNodeWithImageNamed:@"close.png"];
    cancel.position=CGPointMake(265, 300);
    if (self.frame.size.height>500) {
        
        cancel.position=CGPointMake(265, 340);

    }else{
    
        cancel.position=CGPointMake(265, 300);

    }
    cancel.name=@"cancel";
    cancel.zPosition=110;
    [self addChild:cancel];
}

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error{

//    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

    isInterstitialFail=YES;

}

- (void)didCloseInterstitial:(CBLocation)location{
  isInterstitialFail=NO;
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
   [self sendRequestToFrnds];
}

- (void)didDisplayInterstitial:(CBLocation)location{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    isInterstitialFail=NO;


}

-(void)didMoveToView:(SKView *)view{
    BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
        if (connection==YES) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"adMobInterstitial" object:nil];
        }
        
    }
    
    
}


#pragma mark
#pragma mark Send REquest to friends method
#pragma mark ==============================================

-(void) sendRequestToFrnds{
    if (isSuccess==1) {
        [[AppDelegate sharedAppDelegate] showToastMessage:@"Something went wrong please try after some time."];
        return;
    }
    BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
    
    if (netWorkConnection==YES)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        NSLog(@"Tracker %@",tracker);
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SendLifeRequest"     // Event category (required)
                                                              action:@"Refill_Button"  // Event action (required)
                                                               label:@"RefillLife"          // Event label
                                                               value:nil] build]];    // Event value
        

        BOOL facebookConnected=[[NSUserDefaults standardUserDefaults]boolForKey:FacebookConnected];
               if (facebookConnected) {
                   if (!appDelegate) {
                        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                   }

               [self gotoFriendsView];

        }else{
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"You have not logged in with facebook" message:@"Facebook not Connected" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];

        }

    }else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Internet Not Connected" message:@"Check internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    
    }
                                                                                                    
    }


-(void) displayFacebookFriendsList{
    [self gotoFriendsView];
}
-(void) gotoFriendsView{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    if (!appDelegate) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    }

    ViewController *viewCntrler = (ViewController*)[appDelegate getRootViewController];
    CGRect frame = [UIScreen mainScreen].bounds;
    FriendsViewController *fbFrnds = [[FriendsViewController alloc] initWithHeaderTitle:@"Ask for Life"];//WithNibName:@"FriendsViewController" bundle:nil];
    fbFrnds.view.frame = CGRectMake(0, 0, frame.size.height, 0);;
    
    //fbFrnds.headerTitle = @"Ask Life";
    [UIView animateWithDuration:1 animations:^{
        
        fbFrnds.view.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [viewCntrler presentViewController:fbFrnds animated:YES completion:nil];
        //[viewCntrler.view addSubview:fbFrnds.view];
    }];
}

-(void)didEnterBackground:(NSNotification *)notification{
    
    [self.timer invalidate];
    self.timer=nil;
  
}
#pragma mark -
#pragma mark - Background Timer to life over



-(void)timerForLife:(NSTimer *)timer
{
    
    if (sec>0)
    {
        sec--;
        NSLog(@"%ld",(long)sec);
        timeLeftLabel.text=[NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
        
    }
    else if (sec==0 && min!=0)
    {
        sec=59;
        min--;
        timeLeftLabel.text=[NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
        
    }
    
    else if (min==0 && sec==0)
    {
        [self.timer invalidate];
        NSInteger life = [[NSUserDefaults standardUserDefaults] integerForKey:@"life"];

        [[NSUserDefaults standardUserDefaults] setInteger:life forKey:@"life"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
}



#pragma mark  -
#pragma mark - AskFriendButton, moreliveButton, backButton

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //  [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ( [node.name isEqualToString:@"askFriendButton"]) {
        BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
        if (connection==YES) {
            [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];
                [Chartboost showInterstitial:CBLocationStartup];

            [self performSelector:@selector(chartBoostInterstitial) withObject:self afterDelay:6];

//            [self sendRequestToFrnds];
            
        }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Internet " message:@"Please check internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
        
    }
    
    if ( [node.name isEqualToString:@"moreLivesButton"]){
        [self.timer invalidate];
        self.timer = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckTimeForLife" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidEnterBackground" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postSuccess" object:nil];
        SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
        reveal.pausesIncomingScene = TRUE;
        reveal.pausesOutgoingScene=NO;
        AppStore *newScene = [[AppStore alloc] initWithSize:self.size ];
        [self.scene.view presentScene: newScene transition: reveal];
        self.timeLabel=nil;
        self.backButton=nil;
        self.timerTextCnt=nil;
       
        
    }
    
    if ([node.name isEqualToString:@"Back"]) {
        [self.timer invalidate];
        self.timer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckTimeForLife" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidEnterBackground" object:nil];
        
         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postSuccess" object:nil];
        
        [self showLifeOver];
        
        self.timeLabel=nil;
        self.backButton=nil;
        self.timerTextCnt=nil;

        
    }
    
    if ( [node.name isEqualToString:@"cancel"]){
        alertLevel.hidden=YES;
        node.hidden=YES;
        
        [self.timer invalidate];
        self.timer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckTimeForLife" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidEnterBackground" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postSuccess" object:nil];
        
        [self showLifeOver];
        
        self.timeLabel=nil;
        self.backButton=nil;
        self.timerTextCnt=nil;

        
        
    }
    

}

-(void)chartBoostInterstitial{
   [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    if (isInterstitialFail) {
        [self sendRequestToFrnds];
    }
}


-(void) showLifeOver {
    
       self.levelSelection=[[LevelSelectionScene alloc]initWithSize:self.size ];
       [self.scene.view presentScene:self.levelSelection];
}

-(void)compareDate {
    
    NSString *strDate = [userDefault objectForKey:@"strtdate"];
    NSString *strDate1 = [userDefault objectForKey:@"firedate"];

    NSLog(@"Start date %@",strDate);
    NSLog(@"fire date %@ ", strDate1);
  
    
//    if (![strDate isEqualToString:@"0"]) {
    
        NSDate *currentDate = [NSDate date];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSString *strCurrentDate = [formatter stringFromDate:currentDate];
        
        currentDate=[formatter dateFromString:strCurrentDate];
        
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSDate *oldDate = [formatter1 dateFromString:strDate1];
        
        unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond;
        NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSDateComponents *conversionInfo = [gregorianCal components:unitFlags fromDate:oldDate  toDate:currentDate  options:0];
        
            //int months = (int)[conversionInfo month];
        int days = (int)[conversionInfo day];
        int hours = (int)[conversionInfo hour];
        int minutes = (int)[conversionInfo minute];
        int seconds = (int)[conversionInfo second];
        
            //NSLog(@"%d months , %d days, %d hours, %d min %d sec", months, days, hours, minutes, seconds);
        
        [self getExtraLife:days andHour:hours andMin:minutes andSec:seconds];
//    }
}


    //==========================================
-(void)getExtraLife :(int)aday andHour:(int)ahour andMin:(int)amin andSec:(int)asec {
    
//    BOOL notify= [[NSUserDefaults standardUserDefaults] boolForKey:@"checkLivesNotification"];
//    if (notify==YES) {
//        [self setupLocalNotifications];
//    }
    
   int hoursInMin = ahour*60;
    hoursInMin=hoursInMin+amin;
    
    int extralife =amin/5;

    int totalTime = hoursInMin*60+asec;
    
    
    int rem =amin%5;
    
    int remTimeforLife = rem*60+asec;
    
    remTimeforLife=300-remTimeforLife;
    
    
    if (aday>0 || hoursInMin>=50) {
        
//        [userDefault setInteger:10 forKey:@"life"];
//        [userDefault setObject:@"0" forKey:@"strtdate"];
       self.timeLabel.hidden=YES;
        self->timeLeftLabel.text = [NSString stringWithFormat:@"Full with Lives"];

    }
    else if(totalTime>=300){
                            if(extralife>=10){
//                            [userDefault setInteger:10 forKey:@"life"];
//                            [userDefault setObject:@"0" forKey:@"strtdate"];
                               self.timeLabel.hidden=YES;
                        self->timeLeftLabel.text = [NSString stringWithFormat:@"Full with Lives"];
                            }
                            else{
//                                [userDefault setInteger:extralife forKey:@"life"];
                                [self displayRemTime:remTimeforLife];
                                }
                            }
    else{
        
        
        [self displayRemTime:remTimeforLife];
    }
 }


-(void) displayRemTime:(int)aremTime{
    
    NSLog(@"display remaing time");
    remTime = aremTime;
    NSLog(@"remaining time %ld",(long)remTime);
    if (remTime) {
        
        min=remTime/60;
        sec=remTime%60;
        
        int life=(int)[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
        
        if (life <10){
          
          if (sec<10){
            
             self->timeLeftLabel.text = [NSString stringWithFormat:@"%li: 0%li",(long)min,(long)sec];
           
                     }
           else{
            
             self->timeLeftLabel.text = [NSString stringWithFormat:@"%li: 0%li",(long)min,(long)sec];
            
              }
   self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
      }else{
            [self.timer invalidate];
            self.timer=nil;
            self->timeLeftLabel.text = [NSString stringWithFormat:@"Full with Lives"];
            self.timeLabel.hidden=YES;

                   }
        
    }
}


-(void) updateTime{
    
    self->timeLeftLabel.hidden=NO;
    remTime--;
    NSLog(@"remaining time %ld",(long)remTime);
     [[NSUserDefaults standardUserDefaults] setInteger:remTime forKey:@"timeRem"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    min=remTime/60;
    sec=remTime%60;
       NSInteger life2 = [userDefault integerForKey:@"life"];
    if (life2<10) {
        
        if (sec<10) {
            self->timeLeftLabel.text = [NSString stringWithFormat:@"%li: 0%li",(long)min,(long)sec];
        }
        else{
            
            self->timeLeftLabel.text = [NSString stringWithFormat:@"%li: %li",(long)min,(long)sec];
            
        }

    }
    else{
        self->timeLeftLabel.hidden=YES;
    
    }
      if (remTime==0) {
        [self.timer invalidate];
        self.timer=nil;
       NSInteger life = [userDefault integerForKey:@"life"];
        
        life++;
        SKAction *playSound =[SKAction playSoundFileNamed:@"Dusty1-break1.wav" waitForCompletion:NO];
        [self runAction:playSound];
            //    life++;
        
        [userDefault setInteger:1 forKey:@"check"];
          NSDate* now = [NSDate date];
          NSDateFormatter *formate = [[NSDateFormatter alloc] init];
          [formate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
          NSString *dateStr = [formate stringFromDate:now];
          [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"strtdate"];
          [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:@"firedate"];
          
        remTime=300;
        if (life>= 10) {
            [userDefault setInteger:10 forKey:@"life"];
            self->timeLeftLabel.text=[NSString stringWithFormat:@"Full of Life"];
            [userDefault setObject:@"0" forKey:@"strtdate"];
            }
        else{
            [userDefault setInteger:life forKey:@"life"];
            self->timeLeftLabel.text=[NSString stringWithFormat:@"05:00"];
            self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
    }
    [userDefault synchronize];

}

#pragma mark -
#pragma mark - Update method

-(void)update:(NSTimeInterval)currentTime{
   }


#pragma mark--------------------------
/*-(BOOL)shouldDisplayRewardedVideo:(CBLocation)location
{
    return  YES;
}

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward{
    
//    NSLog(@"enetred in redward ");
//    NSInteger life=[[NSUserDefaults standardUserDefaults] integerForKey:@"life"];
//    life=life+reward;
//
// 
//      [[NSUserDefaults standardUserDefaults] setInteger:life forKey:@"life"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//     NSInteger lifed=[[NSUserDefaults standardUserDefaults] integerForKey:@"life"];
    NSLog(@"Life over");
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"life"];
   // [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"eLife"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}*/

#pragma mark -
#pragma mark - setUpFallingStar
- (void)setupSpaceSceneLayers {
    
//    _layerBackgroundNode = [SKNode new];
//    _layerBackgroundNode.name = @"spaceBackgroundNode";
    
        //The last layer added will be on top...add the smallest (furthest away) stars first
    NSString *largeStar = @"star2.png";
    NSString *smallStar = @"star3.png";
    
        //small star layer 1--furthest away
    SKEmitterNode *layer1 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/5) speed:-8 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:NO];
    layer1.zPosition=5;
    
    SKEmitterNode *layer2 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.2 lifetime:(self.frame.size.height/5) speed:-10 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer2.zPosition=10;
    
    SKEmitterNode *layer3 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.6 lifetime:(self.frame.size.height/8) speed:-12 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:YES];
    layer3.zPosition=15;
    
        //small star layer 4--closest
    SKEmitterNode *layer4 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/10) speed:-14 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer4.zPosition=20;
    
    [self addChild:layer1];
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

-(void)checkTimeNotification:(NSNotification *)notification{
    
    NSLog(@"Notification Received");
    [self compareDate];
}
#pragma mark ------------
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
