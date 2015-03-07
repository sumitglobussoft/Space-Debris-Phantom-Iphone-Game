//
//  GameOverScene.h
//  Space Debris
//
//  Created by Globussoft 1 on 6/19/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MyScene.h"

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <sqlite3.h>

@import GoogleMobileAds;
@class AppDelegate;


@interface GameOverScene : SKScene<AVAudioPlayerDelegate, UITextViewDelegate,ChartboostDelegate>

{
    PFObject *secondHighScore;
    BOOL isNewHighScore;
    UIViewController *rootViewController;
    UIActivityIndicatorView *activityInd;
    NSUserDefaults *userDefault;
    AppDelegate *appDelegate;
    UIButton *newGame;
    UIButton *playbutton;
    UIView *backGroundView;
    UIView *highScorePopUp;
    UIView *scoreDisplay;
     UILabel *labelDisplay;
    UIView *highScoreDisplay;
    UIButton *shareFB;
    NSArray *scoreArray2;
    NSArray *ary;
    NSArray *ary1;
    BOOL isInterstitialFail;
    BOOL if_beated;
    UIButton *cancelButton;
    NSString * beatFriendName;
    NSString *beatedFriendFBID;
    UILabel  * beatedFriendLabel;
    UILabel  * highscoreLabel;
    NSString *urlString;
    UILabel  * levelLabel;
    UIView *backView;
    BOOL connection;
    sqlite3 *_databaseHandle;
    
}
-(id)initWithSize:(CGSize)size retryOrNextLevel:(int) option playSound:(int)sound;
@property(nonatomic,weak)NSString *str;
@property(nonatomic,weak)NSString *bestScore;
@property(nonatomic,weak)NSString *strPostMessage;
@property(nonatomic)NSInteger value;
@property(nonatomic)NSInteger soundORnot;
@property (nonatomic, assign) NSInteger currentLevel;
@property(nonatomic,strong)  AVAudioPlayer * _musicPlayer;

@property(nonatomic,retain) NSMutableArray *mutArrScores;
@property(nonatomic, retain) NSString *lblFbFirstName;
@property(nonatomic, retain) NSString *lblFbLastName;
@property(nonatomic, retain) NSMutableArray *mutArray;
@property(nonatomic,retain) NSMutableArray *arrMutableCopy;
@property(nonatomic, retain)NSMutableArray *mutscoreArray;
@property(nonatomic, retain)NSMutableArray *mutFBidArray;
@property(nonatomic,strong)NSMutableArray *mutArray1;
@property(nonatomic,weak)NSArray *aryCount;
@property(nonatomic,strong) UIScrollView  *scrollView;
@property(nonatomic,weak)NSMutableArray *facebookFriendId;
@property(nonatomic)int beatFriendPosition;

@property(nonatomic)int a;
@property(nonatomic)int s;

-(void) saveScoreToParse:(NSInteger)score forLevel:(NSInteger)level;
@end
