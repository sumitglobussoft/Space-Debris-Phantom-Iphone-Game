//
//  NextLevelScene.m
//  Space Debris
//
//  Created by Sumit Ghosh on 29/07/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//


#import "GameOverScene.h"
#import "LifeOver.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MyScene.h"
#import "GameStatus.h"
#import "SBJson.h"
#import "MyScene.h"
#import "Reachability.h"
#import "NextLevelScene.h"
#define RequestTOFacebook @"LifeRequest"
#define ShareToFacebook @"share"
#import "LevelSelectionScene.h"
@implementation NextLevelScene
int yourscore;
@synthesize _musicPlayer,appDelegate;
CGSize ws;
+(SKScene *) scene
{
    // 'scene' is an autorelease object.
	SKScene *scene = [SKScene node];
	
    // 'layer' is an autorelease object.
	NextLevelScene *nextScene = [NextLevelScene node];
	
    // add layer as a child to scene
	[scene addChild: nextScene];
	
    // return the scene
	return scene;
}
-(id)initWithSize:(CGSize)size  playSound:(NSInteger)sound
{
  
    if (self = [super initWithSize:size]) {
        
        self.soundORnot=sound;
        
        SKSpriteNode *background ;
        if ([UIScreen mainScreen].bounds.size.height>500) {
        background=[[SKSpriteNode alloc] initWithImageNamed:@"blankbg1.png"];
        }
        else{
            
            background=[[SKSpriteNode alloc] initWithImageNamed:@"blankbg.png"];
            
        }
        
        background.anchorPoint = CGPointMake(0.5, 1);
        background.position = CGPointMake(self.size.width/2, self.size.height);
        [self addChild:background];
        
        self.remainingCount=2;
        
        SKSpriteNode *share = [[SKSpriteNode alloc] initWithImageNamed:@"shareonfb.png"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
        
            share.position = CGPointMake(160,210);
            
        }else{
            share.position = CGPointMake(160,150);
        }
//        share.position = CGPointMake(160,150);
        share.name=@"share";
        share.zPosition=20;
         [self addChild:share];
        
        SKSpriteNode *next = [[SKSpriteNode alloc] initWithImageNamed:@"next.png"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
            
            next.position = CGPointMake(160, 90);

            
        }else{
            next.position = CGPointMake(160, 70);

        }
       next.name=@"next1";
        next.zPosition=20;
        [self addChild:next];
        
        SKLabelNode *levelDisplay =[[SKLabelNode alloc]initWithFontNamed:@"Party LET"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
         levelDisplay.position=CGPointMake(150, 355);
            
        }else{
            levelDisplay.position=CGPointMake(150, 305);
        }
        levelDisplay.name=@"statusInFriend";
        levelDisplay.fontColor=[UIColor brownColor];
        levelDisplay.text=[NSString stringWithFormat:@"In Level %ld",(long)[GameStatus sharedState].levelNumber ];
        levelDisplay.zPosition=30;
        [self addChild:levelDisplay];
        
        SKLabelNode *statusInFriend=[[SKLabelNode alloc]initWithFontNamed:@"Party LET"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
           statusInFriend.position=CGPointMake(160, 405);
            
        }else{
           statusInFriend.position=CGPointMake(160, 355);
        }
//        statusInFriend.position=CGPointMake(160, 355);
        statusInFriend.name=@"statusInFriend";
        statusInFriend.zPosition=30;
        statusInFriend.fontColor=[UIColor brownColor];
        [self addChild:statusInFriend];
        
        
        SKLabelNode *friendName=[[SKLabelNode alloc]initWithFontNamed:@"Party LET"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
            friendName.position=CGPointMake(160, 380);
        }else{
             friendName.position=CGPointMake(160, 330);
        }


       
        friendName.name=@"statusInFriend";
        friendName.zPosition=30;
        friendName.fontColor=[UIColor brownColor];
        [self addChild:friendName];

       BOOL highScore=[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"HighScore%ld",(long)[GameStatus sharedState].levelNumber ]];
       NSString *friendName1 =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]];
        
        if (highScore==YES){
            
            statusInFriend.text=[NSString stringWithFormat:@"You got Highest Score "];
            
            if (friendName1) {
                friendName.fontSize=20.0;
             friendName.text=[NSString stringWithFormat:@"and beaten %@ ", friendName1 ];
             }
            
        }else if (highScore!=YES && !friendName1) {
            
            statusInFriend.text=[NSString stringWithFormat:@"You got %ld score ",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];

        }
    else {
        
        if (friendName1) {

            statusInFriend.text=[NSString stringWithFormat:@" You  have  Beaten " ];
            friendName.text=[NSString stringWithFormat:@"%@ ", [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]]];
        }
    }
        
//        static NSString *const kFontName1 = @"Party LET"
       SKSpriteNode *backgroundForText=[[SKSpriteNode alloc]initWithImageNamed:@"beatedfriend.png"];
        if ([UIScreen mainScreen].bounds.size.height>500) {
            
            backgroundForText.position = CGPointMake(160,360);
            
        }else{
        backgroundForText.position = CGPointMake(160,310);
        }
        
       backgroundForText.name=@"textBackground";
        backgroundForText.zPosition=20;
        [self addChild:backgroundForText];

        [self setupSpaceSceneLayers];
        
        
        if (self.soundORnot==1) {
            if (_musicPlayer) {
                [_musicPlayer stop];
                _musicPlayer=nil;
                
            }

            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                 pathForResource:@"bgm"
                                                 ofType:@"mp3"]];
                        NSError *error;
            _musicPlayer = [[AVAudioPlayer alloc]
                            initWithContentsOfURL:url
                            error:&error];
            _musicPlayer.numberOfLoops=-1;
            [_musicPlayer prepareToPlay];
            [_musicPlayer play];
        }

        
        
        if ([GameStatus sharedState].levelNumber==40) {
            
            [self popForAllLevelCompletion];
            
        }

        
        
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
   
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
 
    if ([node.name isEqualToString:@"next1"]) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"life"]!=0)
        {
            if (_musicPlayer) {
                [_musicPlayer stop];
                _musicPlayer=nil;
                
            }
            [GameStatus sharedState].levelNumber=[GameStatus sharedState].levelNumber+1;
            [[NSUserDefaults standardUserDefaults] setInteger:[GameStatus sharedState].levelNumber forKey:@"level"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([GameStatus sharedState].levelNumber>40) {
                [GameStatus sharedState].levelNumber=1;
                LevelSelectionScene * levelSelection=[[LevelSelectionScene alloc] initWithSize:self.size];
                [self.view presentScene:levelSelection];
                
            }
            else{
                
                [self switchToNewLevel];
//                MyScene *newScene = [[MyScene alloc] initWithSize:self.size ];
//                    //            [self.scene.view presentScene:newScene];
//                SKTransition *reveal1 = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
//                [self.scene.view presentScene:newScene transition:reveal1];
            }
        }
    }
    if ([node.name isEqualToString:@"share"]) {
        
        if (_musicPlayer) {
            [_musicPlayer stop];
            _musicPlayer=nil;
            
        }
        
        NSLog(@"hiii");
        NSLog(@"connect with facebook button clicked.");
        
       Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];

        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            NSLog(@"stringgk////");
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Sorry ! There is no Internet Connection in your device .You can't share on Facebook" message:@"Check Internet ConnectionFirst" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (status == ReachableViaWiFi)
        {
             appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
             NSString *strLife = [NSString stringWithFormat:@"Level %ld",(long)[GameStatus sharedState].levelNumber];
            NSLog(@"Post Message =-=- %@",self.strPostMessage);
            
            self.strPostMessage = [NSString stringWithFormat:@"I cleared Level %li  and scored %ld points.",(long)[GameStatus sharedState].levelNumber ,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
            NSLog(@"Messaga == %@",self.strPostMessage);

            NSMutableDictionary *params =
            [NSMutableDictionary dictionaryWithObjectsAndKeys:
             self.strPostMessage, @"description", strLife, @"caption",
             @"http://sdp.globusgames.com/", @"link",@"Space Debris Phantom",@"name",
               @"http://www.screencast.com/t/TbZbFgTHJpeR",@"picture",
             nil];
            
            NSDictionary *storyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"level",FacebookType,[NSString stringWithFormat:@"Completed %@",strLife],FacebookTitle,self.strPostMessage,FacebookDescription,@"complete",FacebookActionType, nil];
            
//            appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.openGraphDict = storyDict;
//            [appDelegate openSessionWithLoginUI:1 withParams:params];

                  if (FBSession.activeSession.isOpen) {
                
                   [appDelegate shareOnFacebookWithParams:params islife:@"No"];
               }
                 else{
//                     [appDelegate shareOnFacebookWithParams:params];

                     
                     
                [appDelegate openSessionWithLoginUI:1 withParams:params isLife:@"No"];
                   
//                     [appDelegate openSessionWithLoginUI:1 withParams:params];
               }
//
            NSString *friendName=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]];
            if (friendName) {
                
                SKAction *wait = [SKAction waitForDuration:1.2];
                SKAction *performSel = [SKAction performSelector:@selector(beatFriendStoryPosted) onTarget:self];
                SKAction *sequence = [SKAction sequence:@[performSel, wait]];
                     [self runAction:sequence];
//                           [self schedule:@selector(beatFriendStoryPost) interval:1.2];
            }
            BOOL isHighScore=[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"HighScore%ld",(long)[GameStatus sharedState].levelNumber ]] ;
            if(isHighScore == YES){
                
              SKAction *wait = [SKAction waitForDuration:1.2];
              SKAction *performSel = [SKAction performSelector:@selector(newHighScoreStoryPosted) onTarget:self];
              SKAction *sequence = [SKAction sequence:@[performSel, wait]];
             [self runAction:sequence];
                
                    //        [self schedule:@selector(newHighScoreStoryPost) interval:1.2];
            }

        }
        else if (status == ReachableViaWWAN)
        {
                //3G
        }
            // Do any additional setup after loading the view.
    }
    
}

-(void)switchToNewLevel{

    MyScene *newScene = [[MyScene alloc] initWithSize:self.size ];
    SKTransition *reveal1 = [SKTransition revealWithDirection:SKTransitionDirectionDown duration:1.0];
    [self.scene.view presentScene:newScene transition:reveal1];


}

-(void) newHighScoreStoryPosted{
    
        //    [self unschedule:@selector(newHighScoreStoryPost)];
    NSString *title = [NSString stringWithFormat:@"new highscore %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
    NSString *description = [NSString stringWithFormat:@"Hey i got new highscore %ld in level %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"],(long)[GameStatus sharedState].levelNumber];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"highscore",FacebookType,title,FacebookTitle,description,FacebookDescription,@"set",FacebookActionType, nil];
    
    appDelegate.openGraphDict = dict;
     NSLog(@"high score is achieved");
    [appDelegate storyPostwithDictionary:dict];
}
-(void)beatFriendStoryPosted{
    
        //    [self unschedule:@selector(beatFriendPosition)];
    NSLog(@"Beated friend story");
//    NSString *title = [NSString stringWithFormat:@"beat %@ ",[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"beatenFriendName%ld",(long)[GameStatus sharedState].levelNumber ]]];
    
//    
//    NSString *description = [NSString stringWithFormat:@"%@ at level %ld and made score %ld!",title,(long)[GameStatus sharedState].levelNumber,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
//    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"friend",FacebookType,title,FacebookTitle,description,FacebookDescription,@"beat",FacebookActionType, nil];
//    
//    appDelegate.openGraphDict = dict;
//    [appDelegate storyPostwithDictionary:dict];
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


-(void)update:(NSTimeInterval)currentTime{
    self.remainingCount--;
    
//    if (self.remainingCount==1) {
//        
//        [self addExplosion:CGPointMake(160, 160) withName:@"LifeBarExplosion"];
//        
//    }

    if (self.remainingCount==0) {
        float xPos;
        xPos=RandomFloatRange(0, self.size.width);
        
          float yPos;
        
        yPos=RandomFloatRange(0, self.size.height);
         [self addExplosion:CGPointMake(xPos, yPos) withName:@"HaloExplosion"];
        self.remainingCount=7;
    }
    
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


/*
-(void) shareOnFacebook{
        //---------------------------------------
    
    self.strPostMessage = [NSString stringWithFormat:@"I cleared Level %i  and scored %ld points.",[GameStatus sharedState].levelNumber -1,(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"scoreINlevel"]];
    NSLog(@"Messaga == %@",self.strPostMessage);
    NSString *strLife = [NSString stringWithFormat:@"Level %d",[GameStatus sharedState].levelNumber];
    
    NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     self.strPostMessage, @"description", strLife, @"caption",
     @"http://www.globussoft.com/", @"link",@"Space Debris",@"name",
     //     @"http://i.imgur.com/LaDdDX0.png?1",@"picture",
     nil];
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultUrl, NSError *error){
        
        if (error) {
            NSLog(@"Error to post on facebook = %@", [error localizedDescription]);
        }
        else{
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:ShareToFacebook object:nil];
            
            NSLog(@"result==%u",result);
            NSLog(@"Url==%@",resultUrl);
            if (result == FBWebDialogResultDialogNotCompleted) {
                NSLog(@"Error to post on facebook = %@", [error localizedDescription]);
                NSLog(@"User cancel Request");
            }//End Result Check
            else{
                NSString *sss= [NSString stringWithFormat:@"%@",resultUrl];
                if ([sss rangeOfString:@"post_id"].location == NSNotFound) {
                    NSLog(@"User Cancel Share");
                }
                else{
                    NSLog(@"posted on wall");
                }
            }//End Else Block Result Check
        }
    }];
}
*/
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
