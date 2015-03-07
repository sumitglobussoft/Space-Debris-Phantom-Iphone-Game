//
//  GameOverScene.m
//  Space Debris
//
//  Created by Globussoft 1 on 6/19/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "GameOverScene.h"
#import "LifeOver.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MyScene.h"
#import "Reachability.h"
#import "GameStatus.h"
#import "NextLevelScene.h"
#import "UIImageView+WebCache.h"
#import "SBJson.h"

#define RequestTOFacebook @"LifeRequest"
#import "LevelSelectionScene.h"
#define RequestTOFacebook @"LifeRequest"
#define ShareToFacebook @"FacebookShare"
//static NSString *const kFontName = @"PressStart2P";

static NSString *const kFontName1 = @"Party LET";
static NSString *const kFontName2 = @"sewer.ttf";
CGSize ws;
@implementation GameOverScene
@synthesize str,_musicPlayer;


-(id)initWithSize:(CGSize)size retryOrNextLevel:(int) option  playSound:(int)sound{
    
    
 if (self = [super initWithSize:size]) {
     
    connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
    
     isInterstitialFail=YES;
     
     rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];
     connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
     if (connection==YES) {
        
              NSInteger level=[GameStatus sharedState].levelNumber ;
                 PFQuery * query=[PFQuery queryWithClassName:ParseScoreTableName];
                   [query whereKey:@"Level" equalTo:[NSNumber numberWithInteger:level]];
                 [query orderByDescending:@"Score"];

                 [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                     
                     NSNumber *score=object[@"Score"];
                     [[NSUserDefaults standardUserDefaults] setInteger:[score intValue] forKey:@"BestScore"];
                     [[NSUserDefaults standardUserDefaults] synchronize];

          }];
         
    }
     
     self.mutArray1=[[NSMutableArray alloc] init];
     SKSpriteNode  *background ;
     self.soundORnot=sound;
     if([UIScreen mainScreen].bounds.size.height>500){
         background = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg1.png"];
         
     }else{
         background = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg.png"];
     }
     background.anchorPoint = CGPointMake(0.5, 1);
     background.position = CGPointMake(self.size.width/2, self.size.height);
         //     background.zPosition=20;
         //        background.zPosition = LayerBackground;
     [self addChild:background];
     
     self.value=option;
     
     SKLabelNode *Scoretext = [[SKLabelNode alloc] initWithFontNamed:kFontName];
     Scoretext.fontColor = [UIColor blackColor];
     Scoretext.text =  [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]] ;
     Scoretext.name=@"score";
     Scoretext.fontSize=20.0;
     Scoretext.zPosition=60;
     Scoretext.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
     [self addChild:Scoretext];
     
     SKLabelNode *bestScoretext = [[SKLabelNode alloc] initWithFontNamed:kFontName];
     bestScoretext.fontColor = [UIColor blackColor];
     bestScoretext.fontSize=20.0;
     bestScoretext.text = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"] ];
     bestScoretext.name=@"score";
     bestScoretext.zPosition=60;
     bestScoretext.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
     //     scoreLabel.zPosition = LayerUI;
     [self addChild:bestScoretext];
     
     if([UIScreen mainScreen].bounds.size.height>500){
         Scoretext.position = CGPointMake(220, 270);
         bestScoretext.position = CGPointMake(220, 205);
     }else{
         Scoretext.position = CGPointMake(220, 230);
         bestScoretext.position = CGPointMake(220, 165);
     }

         //     [self spawnObstacle];
     
     
     NSLog(@"str %@",self.str);
     
       if (self.value==2) {
         
           if ([GameStatus sharedState].levelNumber==40) {
               
               [self popForAllLevelCompletion];
               
           }

         NSInteger level=[[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
         NSLog(@"Level clear %ld",(long)level);
         
         if ([GameStatus sharedState].levelNumber>level) {
            [[NSUserDefaults standardUserDefaults] setInteger:[GameStatus sharedState].levelNumber +1 forKey:@"levelClear"];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
       
           
           SKSpriteNode *background1=[SKSpriteNode spriteNodeWithImageNamed:@"level_completed.png"];
           background1.anchorPoint = CGPointMake(0.5, 1);
           if([UIScreen mainScreen].bounds.size.height>500){
               background1.position = CGPointMake(165,520);
               
               
           }else{
               background1.position = CGPointMake(165,470);
               
           }
           background1.zPosition=30;
           [self addChild:background1];

           if([UIScreen mainScreen].bounds.size.height>500){
               Scoretext.position = CGPointMake(220, 280);
               bestScoretext.position = CGPointMake(220, 205);
           }else{
               Scoretext.position = CGPointMake(220, 230);
               bestScoretext.position = CGPointMake(220, 165);
           }

           
         SKSpriteNode *next = [[SKSpriteNode alloc] initWithImageNamed:@"next.png"];
         if([UIScreen mainScreen].bounds.size.height>500){
             next.position = CGPointMake(160, 100);
         }else{
         next.position = CGPointMake(160, 80);
         }
         next.name=@"next";
         next.zPosition=60;
         [self addChild:next];
         

      BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
         
         if (netWorkConnection==YES)
         {
             
             NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
             

             
          if (fbID && ![fbID isEqualToString:@"Master"]) {
            [self saveScoreToParse:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"] forLevel:[GameStatus sharedState].levelNumber];

            [self performSelector:@selector(completedLevelStoryPost) withObject:self afterDelay:1.2];
          }else{
              
              [self retriveScoreSqlite:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"] withLevel:[GameStatus sharedState].levelNumber];
        }
             
             
         }
          else{
         
    [self retriveScoreSqlite:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"] withLevel:[GameStatus sharedState].levelNumber];
         
         }
        
  }
     else{
         
         
         SKSpriteNode *background1=[SKSpriteNode spriteNodeWithImageNamed:@"gameover1.png"];
         background1.anchorPoint = CGPointMake(0.5, 1);
         if([UIScreen mainScreen].bounds.size.height>500){
             background1.position = CGPointMake(165,470);
             
             
         }else{
             background1.position = CGPointMake(165,430);
             
         }
         background1.zPosition=30;
         [self addChild:background1];

         

     SKSpriteNode  *retry=[[SKSpriteNode alloc]initWithImageNamed:@"retry.png"];
         
         if([UIScreen mainScreen].bounds.size.height>500){
             retry.position = CGPointMake(160, 130);
         }else{
             retry.position = CGPointMake(160, 100);

         }

        retry.name=@"retry";
     retry.zPosition=60;
     [self addChild:retry];

     }
     
     
     
     [self setupSpaceSceneLayers];
     
     [self addChild:[self loadEmitterNode:@"stars1"]];
     [self addChild:[self loadEmitterNode:@"stars2"]];
     [self addChild:[self loadEmitterNode:@"stars3"]];
     if (self.soundORnot==1) {
         NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                              pathForResource:@"SpaceGame"
                                              ofType:@"mp3"]];
         
         NSError *error;
         _musicPlayer = [[AVAudioPlayer alloc]
                         initWithContentsOfURL:url
                         error:&error];
         _musicPlayer.numberOfLoops=-1;
         [_musicPlayer prepareToPlay];
       [_musicPlayer play];
     }
     
     
     if (connection==YES) {
         if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
         {
             [[NSNotificationCenter defaultCenter]postNotificationName:@"adMobInterstitial" object:nil];
         }
         
     }

      }
    return  self;
}

-(void)didMoveToView:(SKView *)view{
   /* if (connection==YES) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        {
   [[NSNotificationCenter defaultCenter]postNotificationName:@"adMobInterstitial" object:nil];
        }
        
    }*/


}

/*
- (void)createAndLoadInterstitial {
    
    @try {
        if (!rootViewController) {
             rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];
        }
        
 
        GADInterstitial *interstitial = [[GADInterstitial alloc] init];
            //Testing
        interstitial.adUnitID = @"ca-app-pub-8909749042921180/1782851550";
        
            //Live
            //     interstitial.adUnitID = @"ca-app-pub-7881880964352996/3124406865";
        interstitial.delegate =self ;
        
        GADRequest *request = [GADRequest request];
        
        [interstitial loadRequest:request];
        
        self.interstitial = [[GADInterstitial alloc] init];
        self.interstitial.adUnitID = @"ca-app-pub-8909749042921180/1782851550";
        self.interstitial.delegate = self;
        [self.interstitial loadRequest:[GADRequest request]];

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception callStackSymbols]);
    }
    
    }

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"add received");
    @try {
        if ([self.interstitial isReady]) {
            NSLog(@"inside");
            if ([GameStatus sharedState].isGamePlaying==NO) {
                [self.interstitial presentFromRootViewController:rootViewController];
            }
        }

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception callStackSymbols]);
    }
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    
}*/



- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error{
    
     [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    isInterstitialFail=YES;
    
}

- (void)didCloseInterstitial:(CBLocation)location{
    isInterstitialFail=NO;
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    
    if (if_beated) {
        [self beatFriendStoryPostOnWall];
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life"]!=0) {
        BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
        if (netWorkConnection==YES){
            
            NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
            
            BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
            
            if (facebookConnection) {
                
                if (fbID ) {
                    
                    
                    
                    [self createUI:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
                    
                    [self displayScore:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
                    
                }else{
                    UIButton *btn;
                    [self playButton:btn];
                }
                
            }else{
                UIButton *btn;
                [self playButton:btn];
                
            }
            
        }else{
            UIButton *btn;
            [self playButton:btn];
            
        }
    }

    
}

- (void)didDisplayInterstitial:(CBLocation)location{
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    
    isInterstitialFail=NO;
    
    
}

-(void)popForAllLevelCompletion{
    SKSpriteNode *popUp;
    if([UIScreen mainScreen].bounds.size.height>500){
        popUp=[[SKSpriteNode alloc] initWithImageNamed:@"congratulation.png"];
    }else{
        popUp=[[SKSpriteNode alloc] initWithImageNamed:@"congratulation4.png"];
    }
    
        //    popUp=[[SKSpriteNode alloc] initWithImageNamed:@""];
    popUp.position=CGPointMake(160,240);
    popUp.zPosition=30;
    [self addChild:popUp];
    SKAction *delay=[SKAction waitForDuration:0.80];
    SKAction *remove=[SKAction removeFromParent];
    SKAction *sequence=[SKAction sequence:@[delay,remove]];
    [popUp runAction:sequence];
    
}


-(void) createUI:(NSInteger)score{
      [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    if (!highScorePopUp) {
        NSLog(@"highpopup");
        
        
        
        backGroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        backGroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popupbg2.png"]];
        [rootViewController.view addSubview:backGroundView];
        
        highScorePopUp=[[UIView alloc] init];
        highScorePopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            highScorePopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];
        
        highScorePopUp.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup.png"]];
        [backGroundView addSubview:highScorePopUp];
         scoreDisplay=[[UIView alloc] initWithFrame:CGRectMake(0,25 ,250, 80)];
        scoreDisplay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"beatedfriend2.png"]];
        [highScorePopUp addSubview:scoreDisplay];
        
        
        
        playbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        [playbutton setImage:[UIImage imageNamed:@"play2.png"] forState:UIControlStateNormal];
        
        [playbutton addTarget:self action:@selector(playButton:) forControlEvents:UIControlEventTouchUpInside];
        [highScorePopUp addSubview:playbutton];
        
        shareFB=[UIButton buttonWithType:UIButtonTypeCustom];
        [shareFB setImage:[UIImage imageNamed:@"shareFB.png"] forState:UIControlStateNormal];
        
        [shareFB addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
        [highScorePopUp addSubview:shareFB];
        
        labelDisplay=[[UILabel alloc] init];
        [labelDisplay setFont:[UIFont fontWithName:kFontName1 size:30.0]];
        labelDisplay.text=[NSString stringWithFormat:@"Score :    %ld ",(long)score];
        labelDisplay.textColor=[UIColor blackColor];
        [highScorePopUp addSubview:labelDisplay];
        
        cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [highScorePopUp addSubview:cancelButton];
        

        [highScorePopUp addSubview:beatedFriendLabel];

          [highScorePopUp addSubview:highscoreLabel];
        
        levelLabel=[[UILabel alloc] init];
        [levelLabel setFont:[UIFont fontWithName:kFontName size:15.0]];
        levelLabel.text=[NSString stringWithFormat:@"Level : %d ",(int)[GameStatus sharedState].levelNumber];
        levelLabel.textColor=[UIColor blackColor];
        [highScorePopUp addSubview:levelLabel];
    
//        [GameStatus sharedState].levelNumber=tag;
        NSLog(@"game status shared state %ld",(long)[GameStatus sharedState].levelNumber);
        
        highScoreDisplay=[[UIView alloc] init];
        highScoreDisplay.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            highScoreDisplay.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];
        highScoreDisplay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"highscore.png"]];
        [backGroundView addSubview:highScoreDisplay];
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 120)];
        self.scrollView.backgroundColor = [UIColor clearColor];
        [highScoreDisplay addSubview:self.scrollView];
     
        
        if([UIScreen mainScreen].bounds.size.height>500){
            shareFB.frame=CGRectMake(20, 200, 100, 70);
            highScorePopUp.frame=CGRectMake(30, 80, 250, 310);
            playbutton.frame=CGRectMake(130, 200, 100, 70);
            labelDisplay.frame=CGRectMake(70,100, 150, 40);
            cancelButton.frame=CGRectMake(205, 0, 50, 40);
            highScoreDisplay.frame=CGRectMake(3, 360, self.view.frame.size.width-8, 180);
            levelLabel.frame=CGRectMake(53, 25, 200, 40);
        }
        else{
            cancelButton.frame=CGRectMake(205, 0, 50, 40);
            shareFB.frame=CGRectMake(20, 180, 100, 70);
            highScorePopUp.frame=CGRectMake(30, 25, 250, 270);
            playbutton.frame=CGRectMake(130, 180, 100, 70);
            highScoreDisplay.frame=CGRectMake(3, 285, self.view.frame.size.width-8, 180);
            labelDisplay.frame=CGRectMake(70, 80, 150, 40);
            levelLabel.frame=CGRectMake(53, 25, 200, 40);
           
        }
    }
    else{
        
        [rootViewController.view addSubview:backGroundView];
        backGroundView.hidden = NO;
    }
}


-(void)cancelAction:(UIButton *)button{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];

    backGroundView.hidden = YES;
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    LevelSelectionScene *newScene = [[LevelSelectionScene alloc] initWithSize:self.size ];
    [self.scene.view presentScene: newScene transition: reveal];
    
}

-(void) displayScore:(NSInteger)score{
    
    for (UIView *subView in [self.scrollView subviews]){
        subView.hidden = YES;
    }
    
    scoreArray2 =[GameStatus sharedState].scoreArray;

    if (scoreArray2.count<1) {
        return;
    }
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        for (int i =0; i<scoreArray2.count; i++) {
            PFObject *obj = [scoreArray2 objectAtIndex:i];
            NSLog(@"PFOBJEct -==- %@",obj);
            
            NSNumber *score_saved = obj[@"Score"];
            NSString *player1 = nil;
            NSURL *url = nil;
//            NSString *urlString = nil;
            NSString *name = nil;
            
            player1 = obj[@"PlayerFacebookID"];
//            name = obj[@"Name"];

                        
            url=[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",player1]];
            
//            urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@",player1];
            name =obj[@"Name"];
                //-------------------------------------------------------------
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImageView *aimgeView = (UIImageView*)[self.scrollView viewWithTag:100+i];
                UILabel *label = (UILabel*)[self.scrollView viewWithTag:300+i];
                
                if (aimgeView == nil) {
                    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20+(i*100), 30, 35, 35)];
                    profileImageView.tag = 100+i;
                    [self.scrollView addSubview:profileImageView];
                    [profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
                    [profileImageView.layer setBorderWidth: 2.0];
                    [profileImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                }
                else{
                    aimgeView.hidden = NO;
                    [aimgeView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                }
                
                if (label==nil) {
                    
                    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(i*100), 70, 100, 40)];
                    infoLabel.tag = 300+i;
                    infoLabel.backgroundColor = [UIColor clearColor];
                    infoLabel.font = [UIFont systemFontOfSize:10];
                    infoLabel.numberOfLines = 0;
                    infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    infoLabel.text = [NSString stringWithFormat:@"%@\n%@",name,score_saved];
                    [self.scrollView addSubview:infoLabel];
                    
                    
                    UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+(i*100), 3, 100, 40)];
                    rankLabel.tag = 300+i;
                    rankLabel.backgroundColor = [UIColor clearColor];
                    rankLabel.font = [UIFont systemFontOfSize:10];
                     [rankLabel setFont:[UIFont fontWithName:kFontName size:10.0]];
                    rankLabel.numberOfLines = 0;
                    rankLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    rankLabel.text = [NSString stringWithFormat:@"%d",i+1];
                  [self.scrollView addSubview:rankLabel];
                    

                    
                }
                
                else{
                    
                    label.hidden = NO;
                    label.text = [NSString stringWithFormat:@"%@\n%@",name,score_saved];
                }
                
                
            });
            
        }
        NSLog(@"array count %lu",(unsigned long)scoreArray2.count);
        self.scrollView.contentSize = CGSizeMake(scoreArray2.count*100,120);
    });
    

}

-(void)shareButton:(UIButton *)button{
    if (_musicPlayer) {
        _musicPlayer=nil;
    }
        NSLog(@"connect with facebook button clicked.");
    
    BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
    
     if (netWorkConnection==YES)
    {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *strLife = [NSString stringWithFormat:@"Level %ld",(long)[GameStatus sharedState].levelNumber];

        
        self.strPostMessage = [NSString stringWithFormat:@"Completed level %li with score  %ld.\n  Enjoy the game  in deep blue fathomless sea of stars.",(long)[GameStatus sharedState].levelNumber ,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
        NSLog(@"Messaga == %@",self.strPostMessage);
        
//        NSMutableDictionary *params =
//        [NSMutableDictionary dictionaryWithObjectsAndKeys:
//         self.strPostMessage, @"description", strLife, @"caption",
//         @"https://itunes.apple.com/app/id903882797", @"link",@"Space Debris Phantom",@"name",
//         @"i.imgur.com/20psd4D.png?1",@"picture",
//         nil];
        
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         self.strPostMessage, @"description", @"", @"caption",
         @"https://itunes.apple.com/app/id903882797", @"link",@"Space Debris Phantom",@"name",
         @"i.imgur.com/20psd4D.png?1",@"picture",
         nil];

        
        NSDictionary *storyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"level",FacebookType,[NSString stringWithFormat:@"Completed %@",strLife],FacebookTitle,self.strPostMessage,FacebookDescription,@"complete",FacebookActionType, nil];
        
        appDelegate.openGraphDict = storyDict;
        
        if (FBSession.activeSession.isOpen) {
            
            [appDelegate shareOnFacebookWithParams:params islife:@"No"];
        }
        else{
            
            [appDelegate openSessionWithLoginUI:1 withParams:params isLife:@"No"];
            
        }
        
//        if (isNewHighScore==YES) {
//            
//            [self performSelector:@selector(newHighScoreStoryPost) withObject:nil afterDelay:1.2];
//        }
//        else{
//            if (if_beated==YES) {
//               [self performSelector:@selector(beatFriendStoryPost) withObject:nil afterDelay:1.2];
//            }
//        }
        
    }
   else
    {
        NSLog(@"stringgk////");
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Sorry ! There is no Internet Connection in your device .You can't share on Facebook" message:@"Check Internet ConnectionFirst" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
        // Do any additional setup after loading the view.
}


-(void) newHighScoreStoryPost{
    if (!appDelegate) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    
    NSString *title = [NSString stringWithFormat:@"New highscore %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
    
    
    NSString *description = [NSString stringWithFormat:@"Hey, I got new highscore %ld in level %ld .Enjoy the game  in deep blue fathomless sea of stars.Get ready for an adrenaline rush .",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"],(long)[GameStatus sharedState].levelNumber];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"highscore",FacebookType,title,FacebookTitle,description,FacebookDescription,@"get",FacebookActionType, nil];
    
    appDelegate.openGraphDict = dict;
    if (FBSession.activeSession.isOpen) {

        [appDelegate storyPostwithDictionary:dict];
    }else{
        [appDelegate openSessionWithLoginUI:3 withParams:dict isLife:@"No"];
    }
    
//    if (if_beated==YES) {
//        [self performSelector:@selector(beatFriendStoryPost) withObject:nil afterDelay:1];
//    }
    
    
}

-(void)beatFriendStoryPost{
    
    if (!appDelegate) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    
// NSString *beatFriend = [NSString stringWithFormat:@"Beat %@ ", beatFriendName];
   NSString *title = @"";

    NSLog(@"beat %@",beatFriendName);
    NSString *description = [NSString stringWithFormat:@"Beat %@ at level %ld and got score %ld! .Enjoy the game  in deep blue fathomless sea of stars.Get ready for an adrenaline rush .",beatFriendName,(long)[GameStatus sharedState].levelNumber,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"friend",FacebookType,title,FacebookTitle,description,FacebookDescription,@"beat",FacebookActionType, nil];
    
    appDelegate.openGraphDict = dict;
     if (FBSession.activeSession.isOpen) {
    [appDelegate storyPostwithDictionary:dict];
     }else{
         [appDelegate openSessionWithLoginUI:3 withParams:dict isLife:@"No"];
     }
}

-(void)completedLevelStoryPost{

    BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
    
    BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
    
    if (netWorkConnection==YES)
    {
        
        if (facebookConnection) {
        if (!appDelegate) {
            appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        }
        
        self.strPostMessage = [NSString stringWithFormat:@"Completed Level %li with  score  %ld.Enjoy the game  in deep blue fathomless sea of stars.Get ready for an adrenaline rush .",(long)[GameStatus sharedState].levelNumber ,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
        NSLog(@"Messaga == %@",self.strPostMessage);
        
        
        
         NSDictionary *storyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"level",FacebookType,[NSString stringWithFormat:@""],FacebookTitle,self.strPostMessage,FacebookDescription,@"complete",FacebookActionType, nil];
        
        appDelegate.openGraphDict = storyDict;
        if (FBSession.activeSession.isOpen) {

        [appDelegate storyPostwithDictionary:storyDict];
        }else{
            [appDelegate openSessionWithLoginUI:3 withParams:storyDict isLife:@"No"];
        }
        }
}
}


#pragma mark -
-(void)highScoreAndBeatedFriendStoryPost{


//    NSString *friendName=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]];
    if (beatFriendName) {
        
        SKAction *wait = [SKAction waitForDuration:1.2];
        SKAction *performSel = [SKAction performSelector:@selector(beatFriendStoryPost) onTarget:self];
        SKAction *sequence = [SKAction sequence:@[performSel, wait]];
        [self runAction:sequence];
        
    }
 
    if(isNewHighScore == YES){
        
        SKAction *wait = [SKAction waitForDuration:1.2];
        SKAction *performSel = [SKAction performSelector:@selector(newHighScoreStoryPost) onTarget:self];
        SKAction *sequence = [SKAction sequence:@[performSel, wait]];
        [self runAction:sequence];
        
            //        [self schedule:@selector(newHighScoreStoryPost) interval:1.2];
    }
    


}

#pragma mark -
#pragma mark save score in Squilte.
#pragma mark==================

-(void)retriveScoreSqlite:(NSInteger)ascore withLevel:(NSInteger)alevel
{
    
    BOOL check_Update;
    check_Update=FALSE;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
    NSString * keyLevel=[NSString stringWithFormat:@"%d",(int)alevel];
        // Check to see if the database file already exists
    NSString * connectedFBid=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
    if(!connectedFBid)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey:
         ConnectedFacebookUserID];
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey: @"ConnectedFacebookUserName"];
    }

    NSString *query = [NSString stringWithFormat:@"select * from GameScoreFinal where PlayerFacebookID = \"%@\"",connectedFBid];
    sqlite3_stmt *stmt=nil;
    if(sqlite3_open([databasePath UTF8String], &_databaseHandle)!=SQLITE_OK)
        NSLog(@"error to open");
    
    if (sqlite3_prepare_v2(_databaseHandle, [query UTF8String], -1, &stmt, NULL)== SQLITE_OK)
    {
        NSLog(@"prepared");
    }
    else
        NSLog(@"error");
        // sqlite3_step(stmt);
    @try
    {
        while(sqlite3_step(stmt)==SQLITE_ROW)
        {
            
            char *level = (char *) sqlite3_column_text(stmt,1);
            char *score = (char *) sqlite3_column_text(stmt,2);
            NSString *strLevel= [NSString  stringWithUTF8String:level];
            
            NSString *strScore  = [NSString stringWithUTF8String:score];
            NSLog(@"Level %@ and Score %@ ",strLevel,strScore);
            if([strLevel isEqualToString:keyLevel])
            {
                check_Update=TRUE;
            }
            
        }
    }
    @catch(NSException *e)
    {
        NSLog(@"%@",e);
    }
    if(check_Update)
    {
        [self updateScoreSqlite:ascore withScore:alevel];
    }
    else
    {
        [self saveScoreSqlite:ascore withScore:alevel];
    }
    
}



-(void)saveScoreSqlite:(NSInteger)ascore withScore:(NSInteger)alevel
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
    sqlite3_stmt *inset_statement = NULL;
    NSString * keyLevel=[NSString stringWithFormat:@"%d",(int)alevel];
    NSString * keyScore=[NSString stringWithFormat:@"%d",(int)ascore];
    NSString * connectedFBid=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
    if(!connectedFBid)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey:
         ConnectedFacebookUserID];
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey: @"ConnectedFacebookUserName"];
    }
    connectedFBid=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
    NSString *insertSQL = [NSString stringWithFormat:
                           @"INSERT INTO GameScoreFinal (Level, Score,PlayerFacebookID,Name) VALUES (\"%@\", \"%@\",\"%@\",\"%@\")",
                           keyLevel,
                           keyScore,connectedFBid,[[NSUserDefaults standardUserDefaults]objectForKey:@"ConnectedFacebookUserName"]
                           ];
    
    const char *insert_stmt = [insertSQL UTF8String];
    if (sqlite3_open([databasePath UTF8String], &_databaseHandle)!=SQLITE_OK) {
        NSLog(@"Error to Open");
        return;
    }
    
    if (sqlite3_prepare_v2(_databaseHandle, insert_stmt , -1,&inset_statement, NULL) != SQLITE_OK ) {
        NSLog(@"%s Prepare failure '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(_databaseHandle), sqlite3_errcode(_databaseHandle));
        NSLog(@"Error to Prepare");
        
    }
    
    if(sqlite3_step(inset_statement) == SQLITE_DONE) {
               NSLog(@"Success");
    }
}

-(void)updateScoreSqlite:(NSInteger)ascore withScore:(NSInteger)alevel
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
    sqlite3_stmt *inset_statement = NULL;
    NSString * keyLevel=[NSString stringWithFormat:@"%d",(int)alevel];
    NSString * keyScore=[NSString stringWithFormat:@"%d",(int)ascore];
    NSString * connectedFBid=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
//    [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey: @"ConnectedFacebookUserName"];
    NSString *name=[[NSUserDefaults standardUserDefaults] objectForKey: @"ConnectedFacebookUserName"];
    if(!connectedFBid)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey:
         ConnectedFacebookUserID];
        [[NSUserDefaults standardUserDefaults] setObject:@"Master" forKey: @"ConnectedFacebookUserName"];
    }

    NSLog(@"Exitsing data, Update Please");
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE GameScoreFinal set  Score = '%@', PlayerFacebookID = '%@', Name = '%@' WHERE Level =%@",keyScore,connectedFBid,name,keyLevel];
    
    const char *update_stmt = [updateSQL UTF8String];
    if (sqlite3_open([databasePath UTF8String], &_databaseHandle)!=SQLITE_OK) {
        NSLog(@"Error to Open");
        return;
    }
    
    if (sqlite3_prepare_v2(_databaseHandle, update_stmt , -1,&inset_statement, NULL) != SQLITE_OK )
    {
        NSLog(@"%s Prepare failure '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(_databaseHandle), sqlite3_errcode(_databaseHandle));
        NSLog(@"Error to Prepare");
        
    }
    if(sqlite3_step(inset_statement) == SQLITE_DONE) {
        
        NSLog(@"Success");
    }
        //NSLog(@"%s Prepare failure '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(_databaseHandle), sqlite3_errcode(_databaseHandle));
    sqlite3_finalize(inset_statement);
    sqlite3_close(_databaseHandle);
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

- (SKSpriteNode *)createObstacle {
    
    int imgType = 0;
    
    if (arc4random_uniform != NULL){
        imgType = arc4random_uniform (5);
        NSLog(@"if imgType is %d",imgType);}
    else{
        imgType = (arc4random() % 5);
        NSLog(@"else imgType is %d",imgType);
    }
    
    NSString *loadImageType = [NSString stringWithFormat:@"Debris%d",imgType];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:loadImageType];
    return sprite;
}


-(void)playButton:(UIButton *)button{
    
    
    backGroundView.hidden = YES;
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];


   SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
   LevelSelectionScene *newScene = [[LevelSelectionScene alloc] initWithSize:self.size ];
    [self.scene.view presentScene: newScene transition: reveal];

    newGame=nil;
    playbutton=nil;
    backGroundView=nil;
    highScoreDisplay=nil;
    highscoreLabel=nil;
    highScorePopUp=nil;
    scoreDisplay=nil;
    labelDisplay=nil;
    shareFB=nil;
    scoreArray2=nil;
    cancelButton=nil;
    beatedFriendLabel=nil;
    levelLabel=nil;
    backView=nil;
    self.scrollView=nil;
       [self removeAllActions];
    
}

-(void)beatFriendStoryPostOnWall{

     NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    
    NSString *str3 = [NSString stringWithFormat:@"I beat you in Level %ld with  score  %ld . Enjoy the game  in deep blue fathomless sea of stars.",(long)[GameStatus sharedState].levelNumber,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
    
//    NSMutableDictionary *params =
//    [NSMutableDictionary dictionaryWithObjectsAndKeys:
//     str3, @"description", @"Beat", @"caption",
//     @"https://itunes.apple.com/app/id903882797", @"link",@"Space Debris Phantom",@"name",
//     @"i.imgur.com/20psd4D.png?1",@"picture",beatedFriendFBID,@"to",fbID,@"from",
//     nil];
    
    
   NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     str3, @"description", @"", @"caption",
     @"https://itunes.apple.com/app/id903882797", @"link",@"Space Debris Phantom",@"name",
     @"i.imgur.com/20psd4D.png?1",@"picture",beatedFriendFBID,@"to",fbID,@"from",
     nil];

    if (FBSession.activeSession.isOpen) {
        
        [appDelegate shareOnFacebookWithParams:params islife:@"No"];
    }
    else{
        
        [appDelegate openSessionWithLoginUI:1 withParams:params isLife:@"No"];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
   
   
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAdmobBanner" object:nil];

   
        //if fire button touched, bring the rain
   if ([node.name isEqualToString:@"retry"]||[node.name isEqualToString:@"next"]) {
//       self.admob.view.hidden=YES;
       
       [GameStatus sharedState].remScore=0;
     
       [GameStatus sharedState].remTime=0;
       
       if ( [node.name isEqualToString:@"retry"]) {
           if (_musicPlayer) {
               [_musicPlayer stop];
               _musicPlayer=nil;
           }
           
             if ([[NSUserDefaults standardUserDefaults]integerForKey:@"life"]!=0) {
                
                SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
              MyScene *newScene = [[MyScene alloc] initWithSize:self.size ];
               [self.scene.view presentScene: newScene transition: reveal];
                 
//                 LevelSelectionScene *newScene = [[LevelSelectionScene alloc] initWithSize:self.size ];
//                 [self.scene.view presentScene: newScene transition: reveal];

             }
            else{
                

                
//                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"checkLivesNotification"];
//                [[NSUserDefaults standardUserDefaults]synchronize];
                
                 LifeOver *lifeOver=[[LifeOver alloc] initWithSize:self.size];
                 [self.scene.view presentScene:lifeOver];
//                [ad removeFromSuperview];
//                ad.hidden=YES;
             
            }
           
           newGame=nil;
           playbutton=nil;
           backGroundView=nil;
           highScoreDisplay=nil;
           highscoreLabel=nil;
           highScorePopUp=nil;
           scoreDisplay=nil;
           labelDisplay=nil;
           shareFB=nil;
           scoreArray2=nil;
           cancelButton=nil;
           beatedFriendLabel=nil;
           levelLabel=nil;
           backView=nil;
           self.scrollView=nil;
           [self removeAllActions];

           
        }
       else{
           
           //next Button method
      
           if (connection) {
              
               [Chartboost showInterstitial:CBLocationStartup];
               
           }
        
          if (if_beated) {
               [self beatFriendStoryPostOnWall];
          }
           
   if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life"]!=0) {
 BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
        if (netWorkConnection==YES){
            
            NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
            
            BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
            
            if (facebookConnection) {
                
                if (fbID ) {

            
            
        [self createUI:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
           
        [self displayScore:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
              
                }else{
                    UIButton *btn;
                    [self playButton:btn];
                }
            
                }else{
                UIButton *btn;
                [self playButton:btn];
            
                }

      }else{
           UIButton *btn;
           [self playButton:btn];
       
          }
         }
       
       }
     }
 }


-(void)chartBOOSTInterstitial{
  
    if (isInterstitialFail) {
        if (if_beated) {
            [self beatFriendStoryPostOnWall];
        }
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life"]!=0) {
            BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
            if (netWorkConnection==YES){
                
                NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
                
                BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
                
                if (facebookConnection) {
                    
                    if (fbID ) {
                        
                        
                        
                        [self createUI:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
                        
                        [self displayScore:[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
                        
                    }else{
                          [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                        UIButton *btn;
                        [self playButton:btn];
                    }
                    
                }else{
                      [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                    UIButton *btn;
                    [self playButton:btn];
                    
                }
                
            }else{
                  [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                UIButton *btn;
                [self playButton:btn];
                
            }
        }

    }
}



#pragma mark-
-(void) playRestart{
    backView.hidden = YES;
    backGroundView.hidden = YES;
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;

    }
    
    SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    LevelSelectionScene *newScene = [[LevelSelectionScene alloc] initWithSize:self.size ];
    [self.scene.view presentScene: newScene transition: reveal];

}
-(void) displayGameCompletionView{
    CGRect frame = [UIScreen mainScreen].bounds;
    backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popupbg2.png"]];
    backView.backgroundColor = [UIColor whiteColor];
    [rootViewController.view addSubview:backView];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height+10, frame.size.width, frame.size.height)];
    containerView.backgroundColor = [UIColor clearColor];
    [backView addSubview:containerView];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, frame.size.width-20, 60)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.textColor = [UIColor redColor];
    headerLabel.text = @"Congratulations!";
    [containerView addSubview:headerLabel];
    //--------
    NSString *updatedText = @"You finished all 40 levels in the game. Please rate us and give detailed feedback here .GlobusGames invites you to play our other exciting games in various genres.Visit www.globusgames.com for more.";
    
    UIFont *font = [UIFont systemFontOfSize:17];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:updatedText attributes:dict];
    
    [attributedString addAttribute:NSLinkAttributeName value:@"http://www.globusgames.com" range:[[attributedString string] rangeOfString:@"www.globusgames.com"]];
    [attributedString addAttribute:NSLinkAttributeName value:@"http://www.globusgames.com" range:[[attributedString string] rangeOfString:@"here"]];
    
    UIColor *linkColor = [UIColor colorWithRed:(CGFloat)77/255 green:(CGFloat)161/255 blue:(CGFloat)253/255 alpha:1];
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName:linkColor,NSUnderlineColorAttributeName: linkColor,NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(20, 180, frame.size.width-40, 250)];
    txtView.linkTextAttributes = linkAttributes;
    //txtView.selectable = NO;
    txtView.editable = NO;
    txtView.backgroundColor = [UIColor clearColor];
    txtView.delegate = self;
    [txtView setAttributedText:attributedString];
    [containerView addSubview:txtView];
    
    UIButton *playBtn =[UIButton buttonWithType: UIButtonTypeCustom];
    [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playRestart) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:playBtn];
    playBtn.frame = CGRectMake(frame.size.width/2-55, 400, 100, 70);
    [UIView animateWithDuration:3 animations:^{
        containerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }completion:^(BOOL completed){
        
    }];
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSLog(@"Url = %@",URL);
    //    if ([[URL scheme] isEqualToString:@"username"]) {
    //        NSString *username = [URL host];
    //        NSLog(@"Username == %@",username);
    //        // do something with this username
    //        // ...
    //        return NO;
    //    }
    //[[UIApplication sharedApplication] openURL:URL];
    return YES; // let the system open this URL
}

#pragma mark -
#pragma mark - SaveScoreToTheParse

-(void) saveScoreToParse:(NSInteger)score forLevel:(NSInteger)level{
    
    NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    
//    NSString *strCheckFirstRun = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"levelFirstRun%ld",(long)[GameStatus sharedState].levelNumber ]];
    
    if (fbID && ![fbID isEqualToString:@"Master"]) {
 
        NSArray *allFrndsScore =[GameStatus sharedState].scoreArray;
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:allFrndsScore];
        BOOL isUpdate = NO;
        
        for (int i =0; i<mutableArray.count; i++) {
            PFObject *object = [mutableArray objectAtIndex:i];
            NSString *storeed_fbID =object[@"PlayerFacebookID"];
            if ([fbID isEqualToString:storeed_fbID]) {
                
                isUpdate = YES;
                break;
            }
        }
        
        if (isUpdate==NO) {//if3
            [[NSUserDefaults standardUserDefaults] setObject:@"hello" forKey:[NSString stringWithFormat:@"levelFirstRun%ld",(long)[GameStatus sharedState].levelNumber ]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            PFObject *object = [PFObject objectWithClassName:ParseScoreTableName];
            object[@"PlayerFacebookID"] = fbID;
//            object[@"Level"] = [NSString stringWithFormat:@"%d",(int)level];
            object[@"Score"] = [NSNumber numberWithInteger:score];
            object[@"Name"] =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"ConnectedFacebookUserName"]];
            object[@"Level"] = [NSNumber numberWithInteger:level];
            
             [mutableArray addObject:object];
            
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:NO];
            NSArray* sortedArray = [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [GameStatus sharedState].scoreArray = sortedArray;
            
             BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
            if (facebookConnection) {
                 [self findBeatedFriend:object];
            }
           
            
            NSLog(@"ConnectedFacebookUserName%@",[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"ConnectedFacebookUserName"]]);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [object saveEventually:^(BOOL succeed, NSError *error){
                    
                    if (succeed) {
                        NSLog(@"Save to Parse");
                        
                            //[self retriveFriendsScore:level andScore:score];
                    }
                    if (error) {
                        NSLog(@"Error to Save == %@",error.localizedDescription);
                    }
                }];
            });
        }//if3
        else{
            NSLog(@"Update row................yes ");
            [self updateScoreOn:score level:level];
        }
    }//End FB check
    else{
        NSLog(@"Not connected with Facebook");
    }

}

-(void)findBeatedFriend:(PFObject *)object{
//    if ([GameStatus sharedState].scoreArray==nil) {
//        return;
//    }
    
    NSArray *ary5 = [GameStatus sharedState].scoreArray;
    [self sendPushtoAll:object];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:ary5];
    if ([mutableArray containsObject:object]) {
        
        NSInteger position = [mutableArray indexOfObject:object];
        NSLog(@"Position = %ld",(long)position);
        if (position<=mutableArray.count-2 && mutableArray.count>1) {
            
            NSString *curFBID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
            
            PFObject *beatedObject = [mutableArray objectAtIndex:position+1];
            NSString *beated_fbID = beatedObject[@"PlayerFacebookID"];
            NSLog(@"Beated Friends ID = %@",beatedObject[@"PlayerFacebookID"]);
            NSLog(@"Beated Friends ID = %@",beatedObject[@"Score"]);
            NSLog(@"Beated Friends ID = %@",beatedObject[@"Name"]);
            NSString *name=beatedObject[@"Name"];
           
            if ([beated_fbID isEqualToString:curFBID]) {
                NSLog(@"Set new Score in this level");
                if_beated = NO;
                [mutableArray removeObject:beatedObject];
            }
            else{
                if_beated = YES;
                beatFriendName=beatedObject[@"Name"];
                beatedFriendFBID=beatedObject[@"PlayerFacebookID"];
                beatedFriendLabel=[[UILabel alloc] init];
                [beatedFriendLabel setFont:[UIFont fontWithName:kFontName1 size:30.0]];
                NSString * str1 = name;
                NSArray * arr = [str1 componentsSeparatedByString:@" "];
                NSLog(@"Array values are : %@",arr);
                NSLog(@"Array [0] is :%@",arr[0]);
                
                beatedFriendLabel.text=[NSString stringWithFormat:@"You beat %@",arr[0]];
                beatedFriendLabel.numberOfLines = 0;
                beatedFriendLabel.lineBreakMode = NSLineBreakByCharWrapping;
                if([UIScreen mainScreen].bounds.size.height>500){
                beatedFriendLabel.frame=CGRectMake(40, 130, 200, 50);
                }else{
                beatedFriendLabel.frame=CGRectMake(40, 120, 200, 50);
                }
                beatedFriendLabel.textColor=[UIColor blackColor];
                
          
//                PFQuery *pushQuery = [PFInstallation query];
//                [pushQuery whereKey:@"facebookId" equalTo:beatedFriendFBID];
                // Set channel
//                 NSString *connectUserName= [[NSUserDefaults standardUserDefaults] objectForKey:@"ConnectedFacebookUserName"];
                /*
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                
                NSString *str4=[NSString stringWithFormat:@"%@ beat you in level %ld  ",connectUserName,(long)[GameStatus sharedState].levelNumber];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      str4, @"alert",
                                      @"Increment", @"badge",
                                      @"cheering.caf",@"sound",
                                      @"com.globussoft.spacedebris.UPDATE_STATUS",@"action",
                                      str4,@"Message",
                                      nil];

                
               [push setData:data];
                [push sendPushInBackground];
                */
           
                [self performSelector:@selector(beatFriendStoryPost) withObject:nil afterDelay:0];
            }
            
            
        }
        
        if (position==0) {
            NSLog(@"new high score");
            isNewHighScore = YES;
                        highscoreLabel=[[UILabel alloc] init];
            [highscoreLabel setFont:[UIFont fontWithName:kFontName1 size:30.0]];
            highscoreLabel.text=[NSString stringWithFormat:@" New High Score ! "];
            highscoreLabel.numberOfLines = 0;
            highscoreLabel.lineBreakMode = NSLineBreakByCharWrapping;
            if([UIScreen mainScreen].bounds.size.height>500){
                highscoreLabel.frame=CGRectMake(30, 160, 250, 40);
            }else{
                highscoreLabel.frame=CGRectMake(30, 150, 250, 40);
            }
            
            [highscoreLabel sizeToFit];
            highscoreLabel.textColor=[UIColor blackColor];
            isNewHighScore = YES;
            
            [self performSelector:@selector(newHighScoreStoryPost) withObject:nil afterDelay:0];

        }
        
    }

//    }
}

-(void)sendPushtoAll:(PFObject *)object{
    
    NSArray *compareAry = [GameStatus sharedState].scoreArray;
    if (compareAry.count<1) {
        return;
    }
    
    NSString *curFBID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:compareAry];
    NSMutableArray * Id=[[NSMutableArray alloc]init];
    NSNumber *score = object[@"Score"];
    
    for (int i=0; i<compareAry.count; i++) {
        PFObject *beatedObject = [mutableArray objectAtIndex:i];
        NSString *beated_fbID = beatedObject[@"PlayerFacebookID"];
        NSNumber *check = beatedObject[@"Score"];
        
        if (![beated_fbID isEqualToString:curFBID]) {//1
            
            if (score > check) {
                [Id addObject:beatedObject[@"PlayerFacebookID"]];
            }
        }
    }//for loop
    
    NSLog(@"array is %@",Id);
    
    // push notification .
    
    
    NSString *connectedName = [[NSUserDefaults standardUserDefaults]objectForKey:@"ConnectedFacebookUserName"];
    
    // Create our Installation query
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"facebookId" containedIn:Id];
    NSString *Message = [NSString stringWithFormat:@"%@ beat you in level %ld",connectedName,(long)[GameStatus sharedState].levelNumber];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          Message, @"alert",
                          @"3",@"Type",
                          @"Increment", @"badge",
                          @"cheering.caf",@"sound",
                          @"com.globussoft.spacedebris.UPDATE_STATUS",@"action",
                          Message,@"Message",
                          nil];
    
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}


-(void) updateScoreOn:(NSInteger) score level:(NSInteger) level{
    
    
        NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
        PFQuery *query = [PFQuery queryWithClassName:ParseScoreTableName];
        if(fbID)
        {
            [query whereKey:@"PlayerFacebookID" equalTo:fbID];
            [query whereKey:@"Level" equalTo:[NSNumber numberWithInteger:level]];
            [query orderByDescending:@"Score"];
//              object[@"Level"] = [NSNumber numberWithInteger:level];
                //        NSArray *aryCount=[query findObjects];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"ffff = %@",objects);
                for (int a =0; a<objects.count;a++) {
                    
                    PFObject *object = [objects objectAtIndex:a];
                    
                    if (a==0) {
                        NSLog(@"PFOBJEct -==- %@",object);
                        NSNumber *scoreOld = object[@"Score"];
                        
                        if (score > [scoreOld integerValue]) {
                            
                            
                            NSLog(@"Current Level == %d",(int)level);
                            NSLog(@"Level Score == %d",(int)score);
                            
                        object[@"Score"] = [NSNumber numberWithInteger:score];
                            
                        NSLog(@"%@",[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"ConnectedFacebookUserName"]]);
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                
                                [object saveEventually:^(BOOL succeed, NSError *error){
                                    
                                    if (succeed) {
                                        NSLog(@"Save to Parse");
                                            // [self retriveFriendsScore:level andScore:score];
                                    }
                                    else{
                                        NSLog(@"Error to Save == %@",error.localizedDescription);
                                    }
                                }];
                            });// End dispatch Queue Save Data
                            
                            
                            NSArray *ary6 = [GameStatus sharedState].scoreArray;
                            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:ary6];

                            for (int a =0; a<mutableArray.count;a++){
                                
                                PFObject *obj=[mutableArray objectAtIndex:a];
                                
                                if([obj[@"PlayerFacebookID"] isEqualToString:fbID]){
                                    
                                        // [mutableArray replaceObjectAtIndex:a withObject:object].;
                                    [mutableArray removeObject:obj];
                                    
                                }
                                
                            }
                            [mutableArray addObject:object];
                            
                            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:NO];
                            NSArray* sortedArray = [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                            [GameStatus sharedState].scoreArray = sortedArray;
                            
                            if (score > [scoreOld integerValue])
                            {
                                BOOL facebookConnection=[[NSUserDefaults  standardUserDefaults]boolForKey:FacebookConnected];
                                if (facebookConnection) {
                                    [self findBeatedFriend:object];
                                }
                            }
                        }//End if block Score check
                        
                    }//End if Block a-0
                    else{
                        [object deleteInBackground];
                    }
                    
                }//End of For loop
                
            }];
        }//// End if block fbID check
        
    }


-(void) retriveFriendsScore:(NSInteger)level andScore:(NSInteger)score{
    
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    
    mutArr =[[NSUserDefaults standardUserDefaults] objectForKey:FacebookGameFrindes];

    self.arrMutableCopy = [mutArr mutableCopy];
    
    NSString *strUserFbId = [[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
    NSLog(@"-------------------strUserFbID %@----------------------",strUserFbId);
    
    NSNumber *numFbIdUser =  [NSNumber numberWithLongLong:[strUserFbId longLongValue]];
    NSLog(@"---------------------numFbIdUser %@ ----------------",numFbIdUser);
    
    
    if (![self.arrMutableCopy containsObject:strUserFbId]) {
        [self.arrMutableCopy addObject:strUserFbId];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.currentLevel = level;
        
//        NSString *strLevel = [NSString stringWithFormat:@"%ld",(long)level];
        PFQuery *query = [PFQuery queryWithClassName:ParseScoreTableName];
        
//        [query whereKey:@"Level" equalTo:strLevel];
        [query whereKey:@"PlayerFacebookID" containedIn:self.arrMutableCopy];
        [query whereKey:@"Level" equalTo:[NSNumber numberWithInteger:level]];
        
        [query orderByDescending:@"Score"];
        NSLog(@"query count %ld",(long)[query countObjects]);
//        NSArray *ary2 = [query findObjects];
       [ query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
         
        if (objects.count<1) {
            isNewHighScore = YES;
            NSLog(@"Not contain any Object");
            return;
        }
        
        else{
            NSLog(@"i ma in else condition");
            self.mutArray=[[NSMutableArray alloc] init];
            
                //Commented by me at 16 july
            
            self.mutArrScores = [[NSMutableArray alloc] init];
            
            isNewHighScore = NO;
            for (int i =0; i<ary1.count; i++) {

                PFObject *obj = [ary1 objectAtIndex:i];
                NSLog(@"PFOBJEct -==- %@",obj);
                NSNumber *scoreOld = obj[@"Score"];
                
                NSLog(@"score is------------------%@",scoreOld);
                [self.mutArray addObject:scoreOld];
                
                if (score==[self.mutArray[0] intValue]) {
                    isNewHighScore = YES;
                }
                NSNumber *fbId = obj[@"PlayerFacebookID"];
                NSString *name=obj[@"Name"];
                    //            NSLog(@"Score Old -==- %@",scoreOld);
                
                int storeScore = [scoreOld intValue];
                
                if (score<storeScore) {
                    [self.mutArrScores addObject:scoreOld];
                }
                else{
                    
                    if (self.mutArrScores.count==0) {
                        isNewHighScore = YES;
                        NSLog(@"You create new high Score.");
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"HighScore%ld",(long)[GameStatus sharedState].levelNumber ]] ;
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if ([fbId longLongValue]== [numFbIdUser longLongValue]) {
                            
                              NSLog(@"my position %d",i);
                            
                        }
                        else{
                            NSLog(@"Beated friend name is %@ ",name);
                            
                            [[NSUserDefaults standardUserDefaults] setObject:name forKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                        }
                    }
                    else{
                        
                        if ([fbId longLongValue]== [numFbIdUser longLongValue]) {
                            
                                   NSLog(@"my position %d",i);
                            
                        }
                        else{
                            NSLog(@"Beated friend name is %@ ",name);
                            
                            [[NSUserDefaults standardUserDefaults] setObject:name forKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            NSLog(@"u got %d position in between ur friend ",i+1);
                        }
                    }
                }
            }
            secondHighScore = [ary objectAtIndex:0];
        }
           
       }];
    });
    
    // ===============================================================================
    if (score==[self.mutArray[0] intValue] ) {
        NSLog(@"............................You got higest position...................................");
    }
}

- (void)setupSpaceSceneLayers {

        //The last layer added will be on top...add the smallest (furthest away) stars first
    
    NSString *largeStar = @"star2.png";
    NSString *smallStar = @"star3.png";
    
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

#pragma mark - 
#pragma mark - RevMobAppDelegate


@end
