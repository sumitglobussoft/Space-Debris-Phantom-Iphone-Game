//
//  MyScene.h
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Chartboost/Chartboost.h>
#import "GameResume.h"



typedef NS_ENUM(int, GameState) {
  GameStateMainMenu,
  GameStateTutorial,
  GameStatePlay,
  GameStateFalling,
  GameStateShowingScore,
  GamestatePause,
  GameStateGameOver
};
@interface MyScene : SKScene<AVAudioPlayerDelegate,ChartboostDelegate>
{
    int x;
    int timerStop;
    BOOL isChartBoostWatchSucess;
    BOOL isChartBoostLoadSuccess;
     BOOL isInterstitialFail;
    NSArray *monsterWalkTextures;
    UIViewController *rootViewController;
    UIAlertView *alertHitObstacle;
    UIAlertView *alertHitGround;
    UIAlertView *alertHitGround1;
   NSMutableArray *powerRedFrames;
    NSMutableArray *powerBlueFrames;
    NSMutableArray *simplePlayerFrames;
    SKEmitterNode *bodyEmitterLeft;
    CGSize playerSize;
}

-(id)initWithSize:(CGSize)size;
@property(nonatomic,strong)  AVAudioPlayer * _musicPlayer;
@property (nonatomic, strong) SKNode *layerHudNode;
@property(nonatomic,strong)SKSpriteNode *pauseButton;
@property(nonatomic,strong)SKLabelNode *time;
@property(nonatomic) int timeSec;
@property(nonatomic) int timeMin;
@property(nonatomic)BOOL state;
//@property(nonatomic,strong)SKLabelNode *resumeLabel;
@property(nonatomic,weak)NSTimer *timer1;
@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic,strong) SKLabelNode *Level;
@property(nonatomic,strong) SKLabelNode *lifeLabel;
//@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)SKSpriteNode *musicButton;
@property(nonatomic)int num;
@property(nonatomic)int timeSecCount;
@property(nonatomic)int pauseOrResume;
@property(nonatomic)int handle;
@property(nonatomic)BOOL gameOverDecision;
@property(nonatomic)BOOL obstacleCross;
@property(nonatomic,strong)UIView *resumeView;
@property(nonatomic)SKTexture *texure1;
@property(nonatomic)SKTexture *texure2;
@property (nonatomic, assign) BOOL isPause;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIButton *acceptButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, strong) UIImageView *profileImageView;

@property(nonatomic)BOOL isImmunePowerOn;
@property(nonatomic)NSInteger imunePowerSec;
@property(nonatomic)NSInteger debrisCount;

@property(nonatomic,strong)SKSpriteNode *immunPowerNode;

//-(void)compareDate;

@end
