//
//  LevelSelectionScene.h
//  Space Debris
//
//  Created by Globussoft 1 on 6/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MyScene.h"
#import "GameStartScreen.h"
#import <AVFoundation/AVFoundation.h>
#import "LifeOver.h"

@class LifeOver;
static NSString *const kFontName = @"PressStart2P";
@interface LevelSelectionScene : SKScene<AVAudioPlayerDelegate>
{
    UIButton *btnLevels;
    UIButton *btnBack;
    UIScrollView *scrollView;
    UIViewController *rootViewController;
    SKSpriteNode *background;
    int timeCounter;
    SKSpriteNode *scrollBackground;
    UIView *backGroundView;
    UIView *highScorePopUp;
    UIView *highScoreDisplay;
    UILabel  * namelabel;
    UIButton *playbutton;
    UIButton *cancelButton;
    UIImageView *imgView;
    UILabel  * scorelabel;
    UILabel  * higestScoreLabel;
    UILabel *labelDisplay;
    SKSpriteNode *newgame;
    UIButton *newGame1;
    UIButton *currentLevelButton;
    UIView *viewHost1;
    NSUserDefaults *userDefault;
    SKAction * _missileAction;
    
}
@property(nonatomic,strong) NSMutableArray *nameArray;
@property(nonatomic,strong) NSMutableArray *fbIDArray;
@property(nonatomic,strong) NSMutableArray *scoreArray;
@property(nonatomic,strong)GameStartScreen *gameStartScreen;
@property(nonatomic)LifeOver *lifeOver;
//@property(nonatomic,retain)NSTimer * timer;
@property (nonatomic) CGSize contentSize;
@property(nonatomic) CGPoint contentOffset;
//@property(nonatomic)int timerCount;

@property(nonatomic,strong) UIView *friendsView;
@property(nonatomic,strong) UIScrollView *bottomScroll ;
@property(nonatomic,strong) SKSpriteNode *backButton;
@property(nonatomic,strong)  AVAudioPlayer * _musicPlayer;

-(id)initWithSize:(CGSize)size ;
//-(void)setupBackGround;
+(SKScene *) scene;
//-(void)setContentScale:(CGFloat)scale;
//-(void)setContentOffset:(CGPoint)contentOffset;

@end
