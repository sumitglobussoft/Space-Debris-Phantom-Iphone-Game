//
//  LevelSelectionScene.m
//  Space Debris
//
//  Created by Globussoft 1 on 6/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "LevelSelectionScene.h"
//#import "LevelSelectionViewController.h"
//#import "AppDelegate.h"
#import "GameStartScreen.h"
#import "MyScene.h"
#import "GameOverScene.h"
#import "GameStatus.h"
#import "LifeOver.h"
#import <SpriteKit/SpriteKit.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, IIMySceneZPosition)
{
    kIIMySceneZPositionScrolling = 0,
    kIIMySceneZPositionVerticalAndHorizontalScrolling,
    kIIMySceneZPositionStatic,
};


@interface LevelSelectionScene ()
    @end


@implementation LevelSelectionScene

+(SKScene *) scene
{
        // 'scene' is an autorelease object.
	SKScene *scene = [SKScene node];
	
        // 'layer' is an autorelease object.
	LevelSelectionScene *levelSelection = [LevelSelectionScene node];
	
        // add layer as a child to scene
	[scene addChild: levelSelection];
	
        // return the scene
	return scene;
}

@synthesize _musicPlayer;
-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {

            BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
        
      [[NSUserDefaults standardUserDefaults] setInteger:40 forKey:@"levelClear"];    
        
        if (netWorkConnection) {
            [self findFriendsLevel];

        }
        
        if([UIScreen mainScreen].bounds.size.height>500){
            background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg1.png"];
        }
        else{
            background  = [SKSpriteNode spriteNodeWithImageNamed:@"blankbg.png"];
            
        }
        background.anchorPoint = CGPointMake(0.5, 1);
        background.position = CGPointMake(self.size.width/2, self.size.height);

        [self addChild:background];
              
        scrollBackground= [SKSpriteNode spriteNodeWithImageNamed:@"levelbg.png"];
       scrollBackground.anchorPoint = CGPointMake(0.5, 1);
        scrollBackground.zPosition = 10;
        if ([UIScreen mainScreen].bounds.size.height>500) {
            scrollBackground.position = CGPointMake(self.size.width/2, self.size.height-60);
        }
        else{
            scrollBackground.position = CGPointMake(self.size.width/2, self.size.height-20);
        }

        [self addChild:scrollBackground];
        
        
        [self addChild:[self loadEmitterNode:@"stars1"]];
        [self addChild:[self loadEmitterNode:@"stars2"]];
        [self addChild:[self loadEmitterNode:@"stars3"]];

            //BackButton
        self.backButton=[[SKSpriteNode alloc]initWithImageNamed:@"back.png"];
        self.backButton.position=CGPointMake(self.frame.size.width, self.size.height-20);
        self.backButton.name=@"Back";
        self.backButton.zPosition=70;
        SKAction * run3=[SKAction moveToX:50 duration:4.0];
        [self.backButton runAction: run3];
        [self addChild:self.backButton];
        _missileAction = [SKAction playSoundFileNamed:@"Missle.wav" waitForCompletion:NO];
        [self.backButton runAction:_missileAction];
                
        
      rootViewController = (UIViewController*)[(AppDelegate*)[[UIApplication sharedApplication] delegate] getRootViewController];
 
        if([UIScreen mainScreen].bounds.size.height>500){
            
            scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(25, 100, 270, 250 )];
//               ad.frame = CGRectMake(0, 540, 570, 25);
        }
        else{
             scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(25, 55, 270, 250 )];
//             ad.frame = CGRectMake(0, 455, 470, 25);
         }

         scrollView.contentSize=CGSizeMake(270, 600);
        [scrollView flashScrollIndicators];
        scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
        //[rootViewController.view addSubview:scrollView];
        [rootViewController.view insertSubview:scrollView atIndex:0];

        NSInteger levelNumbers = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        for (int i=0; i<4; i++) {
            
            for (int j=0; j<10; j++) {
               btnLevels = [UIButton buttonWithType:UIButtonTypeSystem];
                
                btnLevels.frame=CGRectMake(15+65*i, 50*j, 48, 48);
                unsigned buttonNumber = j*4+i+1;
                btnLevels.tag=buttonNumber;
                [btnLevels addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
                btnLevels.titleLabel.font=[UIFont fontWithName:@"PressStart2P" size:15];
//                btnLevels.titleLabel.textColor=[UIColor blackColor];
                [btnLevels setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [self runSpinAnimationOnView:btnLevels duration:1.0 rotations:1.0 repeat:0];
                [scrollView addSubview:btnLevels];
            
               
                if (levelNumbers==0) {
                    
                    if (buttonNumber==1) {
                       [btnLevels setBackgroundImage:[UIImage imageNamed:@"clearedlevel.png"] forState:UIControlStateNormal];
                         [btnLevels setTitle:[NSString stringWithFormat:@"%d",buttonNumber] forState:UIControlStateNormal];
                        currentLevelButton = btnLevels;
                    }
                    else{
                       [btnLevels setBackgroundImage:[UIImage imageNamed:@"locklevel.png"] forState:UIControlStateNormal];
                    }
                }
                
                else {
                    
                    if (buttonNumber==levelNumbers) {
                        
                        currentLevelButton = btnLevels;
                       [btnLevels setBackgroundImage:[UIImage imageNamed:@"currentlevel.png"] forState:UIControlStateNormal];
                        NSString *str =[NSString stringWithFormat:@"%ld",(long)btnLevels.tag];
                        [btnLevels setTitle:str forState:UIControlStateNormal];
                    }
                    else if (buttonNumber>levelNumbers) {
                        
                       [btnLevels setBackgroundImage:[UIImage imageNamed:@"locklevel.png"] forState:UIControlStateNormal];
                    }
                    else {
                        
                        [btnLevels setBackgroundImage:[UIImage imageNamed:@"clearedlevel.png"] forState:UIControlStateNormal];
                        NSString *str =[NSString stringWithFormat:@"%ld",(long)btnLevels.tag];
                        [btnLevels setTitle:str forState:UIControlStateNormal];
                        
                    }
                }
            }
        }

        
        [self setupSpaceSceneLayers];
        
        
        [self playMusic];
        timeCounter=0;
        [self performSelector:@selector(animateLevel) withObject:nil afterDelay:1.5];
     }
    
     NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    if (fbID) {
        
    
            [self displayFriendsListUI];
        }
    
       return self;
  }



-(void) addLayerAnimation:(UIButton*)btn{
    
    UIImageView *aimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btn.bounds.size.width, btn.bounds.size.height)];
    aimageView.image = [UIImage imageNamed:@"star4.png"];
    [btn addSubview:aimageView];
    
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnim.toValue = [NSNumber numberWithFloat:0.5];
    fadeAnim.autoreverses = YES;
    fadeAnim.repeatCount = CGFLOAT_MAX;
    fadeAnim.duration = 0.8;
    [aimageView.layer addAnimation:fadeAnim forKey:@"opacity"];
    
    
}


-(void) animateLevel{
    NSInteger levelNumbers = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
    
    CGFloat h = 0;
    if (levelNumbers>16 && levelNumbers <= 24) {
        //[scrollV setContentOffset:CGPointMake(0, 150)];
        h = 150;
    }
    else if (levelNumbers > 24 && levelNumbers < 32){
        // [scrollV setContentOffset:CGPointMake(0, 200)];
        h = 200;
    }
    else if (levelNumbers >= 32){
        // [scrollV setContentOffset:CGPointMake(0, 250)];
        h = 250;
    }
    else{
        //[scrollV setContentOffset:CGPointZero];
        h = 0;
    }
    float time = levelNumbers/20;
    if (time<1) {
        time = 1;
    }
    [UIView animateWithDuration:time animations:^{
        
    }completion:^(BOOL finished){
        if (finished == YES) {
            
            [self addLayerAnimation:currentLevelButton];
        }
    }];
    [UIView animateWithDuration:time animations:^{
        [scrollView setContentOffset:CGPointMake(0, h)];
    }];
}


#pragma mark -
#pragma mark Find Friends Level

-(void)findFriendsLevel{
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    mutArr =[[NSUserDefaults standardUserDefaults] objectForKey:FacebookGameFrindes];
    NSLog(@"MutArray %@",mutArr);
    if (mutArr.count<1) {
        return;
    }
    
    
    NSMutableArray * level=[[NSMutableArray alloc]init];
    NSMutableArray * name=[[NSMutableArray alloc]init];
    NSMutableArray * Id=[[NSMutableArray alloc]init];
    
   
    PFQuery * query=[PFQuery queryWithClassName:ParseScoreTableName];
    [query whereKey:@"PlayerFacebookID" containedIn:mutArr];
    [query orderByDescending:@"Level"];

  
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSArray * arr=[query findObjects];
       [ query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
        for (int j=0; j<objects.count; j++) {
            PFObject * obj=[objects objectAtIndex:j];
            for(int k=0;k<mutArr.count;k++)
            {
                if(![Id containsObject:obj[@"PlayerFacebookID"]])
                {
                    [level addObject:obj[@"Level"]];
                    [name addObject:obj[@"Name"]];
                    [Id addObject:obj[@"PlayerFacebookID"]];
                }
            }
        }
        
        NSLog(@"Level %@",level);
        for(int i=0;i<level.count;i++)
        {
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",Id[i]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIImageView *aimgeView = (UIImageView*)[self.friendsView viewWithTag:100+i];
                UILabel *label = (UILabel*)[self.friendsView viewWithTag:300+i];
                UILabel *positionLabel=(UILabel*)[self.friendsView viewWithTag:3000+i];
                if (aimgeView == nil) {
                    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20+(i*90), 60, 35, 35)];
                    profileImageView.tag = 100+i;
                    profileImageView.tag = 100+i;
                    profileImageView.layer.borderWidth=2;
                    profileImageView.layer.borderColor=[[UIColor orangeColor]CGColor];
                    
                    [self.bottomScroll addSubview:profileImageView];
                    [profileImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58x58.png"]];
                }
                else{
                    aimgeView.hidden = NO;
                    [aimgeView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58x58.png"]];
                }
                if (label==nil) {
                    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(i*90), 100, 90, 35)];
                    infoLabel.tag = 300+i;
                    infoLabel.backgroundColor = [UIColor clearColor];
                    infoLabel.font = [UIFont systemFontOfSize:10];
                    infoLabel.numberOfLines = 0;
                    infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    infoLabel.text = [NSString stringWithFormat:@"%@",name[i]];
                    [self.bottomScroll addSubview:infoLabel];
                    
                    [infoLabel sizeToFit];
                }
                else{
                    label.hidden = NO;
                    label.text = [NSString stringWithFormat:@"%@",name[i]];
                    [label sizeToFit];
                }
                
                
                if(positionLabel==nil)
                {
                    
                    
                    UILabel * position=[[UILabel alloc] initWithFrame:CGRectMake(35+(i*90), 30, 30, 45)];
                    position.tag = 3000+i;
                    position.textColor = [UIColor orangeColor];
                    position.backgroundColor=[UIColor clearColor];
                    [position setFont:[UIFont fontWithName:@"ShallowGraveBB" size:20]];
                    position.numberOfLines = 0;
                    position.lineBreakMode = NSLineBreakByCharWrapping;
                    position.text = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@", level[i]]];
                    [self.bottomScroll addSubview:position];
                    
                }
                else
                {
                    positionLabel.hidden=NO;
                    positionLabel.text = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@", level[i]]];
                    
                    
                }
                
                
            });
        }
           
       }];
    });
    
    
}



#pragma mark -
#pragma mark Display Friend UI
-(void)displayFriendsListUI{
  
    NSMutableArray *mutArr1 = [[NSMutableArray alloc]init];
    mutArr1 =[[NSUserDefaults standardUserDefaults] objectForKey:FacebookGameFrindes];
//    if (mutArr1.count<1) {
//        return;
//    }
    if(!self.friendsView)
    {
        self.friendsView=[[UIView alloc]init];
        if([UIScreen mainScreen].bounds.size.height<500)
        {
            self.friendsView.frame=CGRectMake(10, 320, 295, 160);
        }
        else{
            self.friendsView.frame=CGRectMake(10, 400, 295, 160);
        }
        //self.friendsView.backgroundColor=[UIColor colorWithRed:(CGFloat)183/255 green:(CGFloat)222/255 blue:(CGFloat)243/255 alpha:0.7];
        self.friendsView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"friends_current_level.png"]];
        self.friendsView.layer.cornerRadius=4;
        self.friendsView.clipsToBounds=YES;
        [rootViewController.view addSubview:self.friendsView];
    }
    self.friendsView.hidden=NO;
    if(!self.bottomScroll)
    {
        self.bottomScroll=[[UIScrollView alloc]init];
        self.bottomScroll.frame=CGRectMake(0, 10, self.friendsView.frame.size.width,self.friendsView.frame.size.height);
        self.bottomScroll.backgroundColor=[UIColor clearColor];
        [self.friendsView addSubview:self.bottomScroll];
    }
    self.bottomScroll.hidden=NO;
    
    self.bottomScroll.contentSize=CGSizeMake(mutArr1.count*40, self.bottomScroll.frame.size.height);
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




-(void)cancelAction:(UIButton *)button{
    newgame.hidden=NO;
    self.userInteractionEnabled=YES;
    self.backButton.hidden = NO;
    backGroundView.hidden = YES;
    self.friendsView.hidden=NO;
    
}


-(void)btnAction:(UIButton *)button{
    
    [GameStatus sharedState].levelNumber=[button tag];
    NSLog(@"level here is %ld",(long)[GameStatus sharedState].levelNumber);
    self.friendsView.hidden=YES;
    
    NSInteger levelNumbers = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
    
    
    if (levelNumbers < [button tag] && levelNumbers != 0) {
        return;
    }
    
    
    self.backButton.hidden = YES;
    
      NSInteger life= [[NSUserDefaults standardUserDefaults] integerForKey:@"life"];
        
        NSInteger selectedLevel = [button tag];
        
        if (life>0) {
//            newGame.hidden=YES;
             BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
//            NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];

            
                
           if (connection==YES){
//            if (fbID) {
               [self createUI:selectedLevel];

                NSLog(@"Fetched score from parse and display play option");
                [self retriveFriendsScore:selectedLevel];
               
//            }
               
            }// if fb check
            else{
                NSLog(@"display Play option with selected level");
                [self playButton:button];
            }// else fb check
            
        }// if life check
        else{
            NSLog(@"Display game over Scene");
            scrollView.hidden=YES;
//            [self compareDate];
            [self showLifeOver];
            
        }
 }

-(void) retriveFriendsScore:(NSInteger)level {
    
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    mutArr =[[NSUserDefaults standardUserDefaults] objectForKey:FacebookGameFrindes];
    
    if (mutArr.count!=0) {
  
    NSString *curFBID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    NSArray *allAry = [mutArr arrayByAddingObject:curFBID];
    PFQuery *query = [PFQuery queryWithClassName:ParseScoreTableName];
    [query whereKey:@"Level" equalTo:[NSNumber numberWithInteger:level]];
    [query whereKey:@"PlayerFacebookID" containedIn:allAry];
    [query orderByDescending:@"Score"];
    
    for (UIView *subView in [highScoreDisplay subviews]){
        subView.hidden = YES;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count!=0) {
              
            
            [GameStatus sharedState].scoreArray= [NSArray arrayWithArray:objects];

        for (int i =0; i<objects.count; i++) {
            if (i == 3) {
                break;
            }
            PFObject *obj = [objects objectAtIndex:i];
            NSLog(@"PFOBJEct -==- %@",obj);
            
            NSNumber *score = obj[@"Score"];
            NSString *name = obj[@"Name"];
            NSString *player1 = obj[@"PlayerFacebookID"];
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",player1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *aimgeView = (UIImageView*)[highScoreDisplay viewWithTag:100+i];
                UILabel *label = (UILabel*)[highScoreDisplay viewWithTag:300+i];
                
                if (aimgeView == nil) {
                    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20+(i*100), 70, 35, 35)];
                    profileImageView.tag = 100+i;
                    [highScoreDisplay addSubview:profileImageView];
                    [profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
                    [profileImageView.layer setBorderWidth: 2.0];

                    [profileImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                }
                else{
                    aimgeView.hidden = NO;
                    [aimgeView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                }
                
                if (label==nil) {
               UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(i*100), 110, 100, 35)];
                    infoLabel.tag = 300+i;
                    infoLabel.backgroundColor = [UIColor clearColor];
                    infoLabel.font = [UIFont systemFontOfSize:10];
                    infoLabel.numberOfLines = 0;
                    infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    infoLabel.text = [NSString stringWithFormat:@"%@\n%@",name,score];
                    [highScoreDisplay addSubview:infoLabel];
                    
                    [infoLabel sizeToFit];
                    
                    UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(35+(i*100), 35, 100, 40)];
                    rankLabel.tag = 300+i;
                    rankLabel.backgroundColor = [UIColor clearColor];
                    rankLabel.font = [UIFont systemFontOfSize:10];
                    [rankLabel setFont:[UIFont fontWithName:kFontName size:10.0]];
                    rankLabel.numberOfLines = 0;
                    rankLabel.lineBreakMode = NSLineBreakByCharWrapping;
                    rankLabel.text = [NSString stringWithFormat:@"%d",i+1];
                    [highScoreDisplay addSubview:rankLabel];

                }
                else{
                    label.hidden = NO;
                    label.text = [NSString stringWithFormat:@"%@\n%@",name,score];
                    [label sizeToFit];
                }
                
            });
            
              }
            }else{
            //if no facebook friend has reached to current  Level
                [self findRandomUsersLevelScore:level];

            }
        }];
    });
        //if no Facebook friend found then show top Highscore of Levels
    }else{
        [self findRandomUsersLevelScore:level];
        
    }
}


-(void)findRandomUsersLevelScore:(NSInteger)level{

    PFQuery *query = [PFQuery queryWithClassName:ParseScoreTableName];
    [query whereKey:@"Level" equalTo:[NSNumber numberWithInteger:level]];
    [query setLimit:5];
    [query orderByDescending:@"Score"];
    for (UIView *subView in [highScoreDisplay subviews]){
        subView.hidden = YES;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects.count!=0) {
                
//            [GameStatus sharedState].scoreArray= [NSArray arrayWithArray:objects];
                [GameStatus sharedState].scoreArray= nil;

            for (int i =0; i<objects.count; i++) {
                if (i == 3) {
                    break;
                }
                PFObject *obj = [objects objectAtIndex:i];
                NSLog(@"PFOBJEct -==- %@",obj);
                
                NSNumber *score = obj[@"Score"];
                NSString *name = obj[@"Name"];
                NSString *player1 = obj[@"PlayerFacebookID"];
                NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",player1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *aimgeView = (UIImageView*)[highScoreDisplay viewWithTag:100+i];
                    UILabel *label = (UILabel*)[highScoreDisplay viewWithTag:300+i];
                    
                    if (aimgeView == nil) {
                        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20+(i*100), 70, 35, 35)];
                        profileImageView.tag = 100+i;
                        [highScoreDisplay addSubview:profileImageView];
                        [profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
                        [profileImageView.layer setBorderWidth: 2.0];
                        
                        [profileImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                    }
                    else{
                        aimgeView.hidden = NO;
                        [aimgeView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"58.png"]];
                    }
                    
                    if (label==nil) {
                        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(i*100), 110, 100, 35)];
                        infoLabel.tag = 300+i;
                        infoLabel.backgroundColor = [UIColor clearColor];
                        infoLabel.font = [UIFont systemFontOfSize:10];
                        infoLabel.numberOfLines = 0;
                        infoLabel.lineBreakMode = NSLineBreakByCharWrapping;
                        infoLabel.text = [NSString stringWithFormat:@"%@\n%@",name,score];
                        [highScoreDisplay addSubview:infoLabel];
                        
                        [infoLabel sizeToFit];
                        
                        UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(35+(i*100), 35, 100, 40)];
                        rankLabel.tag = 300+i;
                        rankLabel.backgroundColor = [UIColor clearColor];
                        rankLabel.font = [UIFont systemFontOfSize:10];
                        [rankLabel setFont:[UIFont fontWithName:kFontName size:10.0]];
                        rankLabel.numberOfLines = 0;
                        rankLabel.lineBreakMode = NSLineBreakByCharWrapping;
                        rankLabel.text = [NSString stringWithFormat:@"%d",i+1];
                        [highScoreDisplay addSubview:rankLabel];
                        
                    }
                    else{
                        label.hidden = NO;
                        label.text = [NSString stringWithFormat:@"%@\n%@",name,score];
                        [label sizeToFit];
                    }
                    
                });
                
            }
            }else{
            
            
            }
            
            
        }];
    });
    
}

-(void) createUI:(NSInteger)tag{
    newgame.hidden=YES;
    self.userInteractionEnabled=NO;
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
        
        newGame1 =[UIButton buttonWithType:UIButtonTypeCustom];
        [newGame1 setImage:[UIImage imageNamed:@"newgame.png" ] forState:UIControlStateNormal];
        newGame1.transform = CGAffineTransformMakeScale(1.1,1.1);
        [highScorePopUp addSubview:newGame1];
        [newGame1 addTarget:self action:@selector(newGame:) forControlEvents:UIControlEventTouchUpInside];
        
        
            cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [cancelButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        
            [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
            [highScorePopUp addSubview:cancelButton];
        
        
            playbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [playbutton setImage:[UIImage imageNamed:@"play2.png"] forState:UIControlStateNormal];
        
            [playbutton addTarget:self action:@selector(playButton:) forControlEvents:UIControlEventTouchUpInside];
          [highScorePopUp addSubview:playbutton];
        
        UIImageView *imageview1=[[UIImageView alloc] initWithFrame:CGRectMake(75, 80, 90, 100)];
        imageview1.image=[UIImage imageNamed:@"bg-galaxy_b.png"];
        [highScorePopUp addSubview:imageview1] ;
        
        UIImageView *imageview2=[[UIImageView alloc] init ];
        if([UIScreen mainScreen].bounds.size.height>500){
            
         imageview2.frame= CGRectMake(175, 210, 50, 50);
        }else{
            imageview2.frame= CGRectMake(175, 200, 50, 50);
        }
        
        imageview2.image=[UIImage imageNamed:@"Astronaut.png"];
        [highScorePopUp addSubview:imageview2] ;

        
        [GameStatus sharedState].levelNumber=tag;
        NSLog(@"game status shared state %ld",(long)[GameStatus sharedState].levelNumber);
        highScoreDisplay=[[UIView alloc] init ];
        highScoreDisplay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"highscore.png"]];
        highScoreDisplay.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            highScoreDisplay.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];

            [backGroundView addSubview:highScoreDisplay];
        
        labelDisplay=[[UILabel alloc] init];
        [labelDisplay setFont:[UIFont fontWithName:kFontName size:18.0]];
        labelDisplay.text=[NSString stringWithFormat:@"Level : %ld ",(long)tag];
        labelDisplay.textColor=[UIColor blackColor];
        [highScorePopUp addSubview:labelDisplay];
        
        if([UIScreen mainScreen].bounds.size.height>500){
            
            highScorePopUp.frame=CGRectMake(30, 80, 250, 310);
            cancelButton.frame=CGRectMake(205, 0, 50, 40);
            newGame1.frame = CGRectMake(30, 220, 60, 50);
            playbutton.frame=CGRectMake(80, 170, 100, 70);
            labelDisplay.frame=CGRectMake(40, 20, 200, 40);
            highScoreDisplay.frame=CGRectMake(3, 360, self.view.frame.size.width-8, 180);
        }
        else{
            
            newGame1.frame = CGRectMake(30, 200, 60, 50);
            labelDisplay.frame=CGRectMake(40,40, 200, 40);
            highScorePopUp.frame=CGRectMake(30, 25, 250, 270);
            cancelButton.frame=CGRectMake(205, 0, 50, 40);
            playbutton.frame=CGRectMake(80, 170, 100, 70);
            highScoreDisplay.frame=CGRectMake(3, 285, self.view.frame.size.width-8, 180);
        }
    }
    else{
        
        [rootViewController.view addSubview:backGroundView];
        
        highScorePopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            highScorePopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];
        
        highScoreDisplay.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.3 delay:.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            highScoreDisplay.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
        }];
        
        
        backGroundView.hidden = NO;
      labelDisplay.text=[NSString stringWithFormat:@"Level %ld ",(long)tag];
    }
}


-(void)newGame:(UIButton *)button{
   }
     
-(void)playButton:(UIButton *)button{
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
        
    }
    NSNumber * buttonTag=[NSNumber numberWithInteger:[button tag]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSLog(@"Tracker %@",tracker);
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Play"     // Event category (required)
                                                          action:@"Play_button"  // Event action (required)
                                                           label:@"play"          // Event label
                                                           value:buttonTag] build]];    // Event value
    
 backGroundView.hidden = YES;
    self.friendsView.hidden=YES;

    NSInteger extraLife = [[NSUserDefaults standardUserDefaults] integerForKey:@"eLife"];
    NSInteger life = [[NSUserDefaults standardUserDefaults] integerForKey:@"life"];
    life=life+extraLife;
    if (life>10) {
      // [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"life"];
      //   [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"strtdate"];
    }else
    [[NSUserDefaults standardUserDefaults] setInteger:life forKey:@"life"];
    
    if (extraLife>0) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"eLife"];
    }

    
    if ([button isKindOfClass:[UIButton class]]) {
        NSLog(@"Sender Button Tag =-=-=- %ld",(long)[button tag]);
//        [GameStatus sharedState].levelNumber=[button tag];
        
        if ([button tag] ==1) {
            [[NSUserDefaults standardUserDefaults] setInteger:[button tag] forKey:@"level"];
            scrollView.hidden=YES;
//            [_musicPlayer stop];
            SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionLeft duration:1.0];
            reveal.pausesIncomingScene =YES;
            reveal.pausesOutgoingScene=YES;
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life" ]==0) {
                [self showLifeOver];
                    //                [self.scene.view presentScene:nil];
            }
            else{
                MyScene *newScene = [[MyScene alloc] initWithSize:self.size  ];
                    //            [self.scene.view presentScene:nil];
                [self.scene.view presentScene:newScene];
                
            }
        }
        
        else {
            NSInteger levelNumbers = [[NSUserDefaults standardUserDefaults] integerForKey:@"levelClear"];
            NSLog(@"level Number %ld",(long)levelNumbers);
            
            
            if ([button tag] <= levelNumbers) {
                [[NSUserDefaults standardUserDefaults] setInteger:[button tag] forKey:@"level"];
                scrollView.hidden=YES;
//                [_musicPlayer stop];
                SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionLeft duration:1.0];
                reveal.pausesIncomingScene = YES;
                reveal.pausesOutgoingScene=YES;
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life" ]==0) {
                    [self showLifeOver];
                }
                else{
                    
                    MyScene *newScene = [[MyScene alloc] initWithSize:self.size ];
                    [self.scene.view presentScene: newScene transition: reveal];
                    
                }
            }
            else{
                
            }
        }


        
        btnLevels=nil;
        btnBack=nil;
        scrollView=nil;
        rootViewController=nil;
        background=nil;
        scrollBackground=nil;
        backGroundView=nil;
        highScoreDisplay=nil;
        highScorePopUp=nil;
        namelabel=nil;
        playbutton=nil;
        cancelButton=nil;
        imgView=nil;
        scorelabel=nil;
        higestScoreLabel=nil;
        labelDisplay=nil;
        currentLevelButton=nil;
        viewHost1=nil;
//        if ( self.fbIDArray) {
//            self.fbIDArray=nil;
//        }
//        if ( self.scoreArray) {
//             self.scoreArray=nil;
//        }
     
        
    }
    
}



-(void) showLifeOver {
    if (_musicPlayer) {
        [_musicPlayer stop];
        _musicPlayer=nil;
    }
  
       self.lifeOver=[[LifeOver alloc] initWithSize:self.size];
      [self.scene.view presentScene:self.lifeOver ];
    scrollView.hidden=YES;
    btnLevels.hidden=YES;

    
  }

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   
    
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
       if ([node.name isEqualToString:@"Back"]) {
           if (_musicPlayer) {
               [_musicPlayer stop];
               _musicPlayer=nil;
               
           }

        self.gameStartScreen=[[GameStartScreen alloc] initWithSize:self.size];
        scrollView.hidden=YES;
         [self.scene.view presentScene:self.gameStartScreen];
           self.friendsView.hidden=YES;
           
           
           btnLevels=nil;
           btnBack=nil;
           scrollView=nil;
           rootViewController=nil;
           background=nil;
           scrollBackground=nil;
           backGroundView=nil;
           highScoreDisplay=nil;
           highScorePopUp=nil;
           namelabel=nil;
           playbutton=nil;
           cancelButton=nil;
           imgView=nil;
           scorelabel=nil;
           higestScoreLabel=nil;
           labelDisplay=nil;
           currentLevelButton=nil;
           viewHost1=nil;
           if (self.fbIDArray) {
               self.fbIDArray=nil;
           }
           if (self.scoreArray) {
               self.scoreArray=nil;
           }
           
           
     }
    if ([node.name isEqualToString:@"Newgame"]) {
        
    }


}

-(void)update:(NSTimeInterval)currentTime{
    
}

#pragma mark -
-(void)compareDateAndTime {
    
    NSString *strDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"strtdate"];
    
    if (![strDate isEqualToString:@"0"]) {
        
        NSDate *currentDate = [NSDate date];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSString *strCurrentDate = [formatter stringFromDate:currentDate];
        
        currentDate=[formatter dateFromString:strCurrentDate];
        
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSDate *oldDate = [formatter1 dateFromString:strDate];
        
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
    }
    else{
        
              
    }
}


    //==========================================

-(void)getExtraLife :(int)aday andHour:(int)ahour andMin:(int)amin andSec:(int)asec {
    
//    BOOL notify= [[NSUserDefaults standardUserDefaults] boolForKey:@"checkLivesNotification"];
//    if (notify==YES) {
////        [self setupLocalNotifications];
//    }
//    int life=(int)[userDefault integerForKey:@"life"];
    int hoursInMin = ahour*60;
    hoursInMin=hoursInMin+amin;
    
    int extralife =amin/5;
    
    int totalTime = hoursInMin*60+asec;
    
//   int rem =amin%5;
    
//    int remTimeforLife = rem*60+asec;
    
//    remTimeforLife=300-remTimeforLife;
    
    
    if (aday>0 || hoursInMin>=50) {
        
        [userDefault setInteger:10 forKey:@"life"];
        [userDefault setObject:@"0" forKey:@"strtdate"];
    }
    else if(totalTime>=300){
        if(extralife>=10){
            [userDefault setInteger:10 forKey:@"life"];
            [userDefault setObject:@"0" forKey:@"strtdate"];
            
        }
        else{
            [userDefault setInteger:extralife forKey:@"life"];
//            [self displayRemTime:remTimeforLife];
        }
    }
    else{
        
        }
    [userDefault synchronize];
}

#pragma mark -
#pragma mark - Background Timer

- (void)setupSpaceSceneLayers {
    
    NSString *largeStar = @"star2.png";
    NSString *smallStar = @"star3.png";
    
    SKEmitterNode *layer2 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.2 lifetime:(self.frame.size.height/5) speed:-10 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    layer2.zPosition=1;
    
    SKEmitterNode *layer3 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.6 lifetime:(self.frame.size.height/8) speed:-12 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:YES];
    layer3.zPosition=2;
    
    
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



@end
