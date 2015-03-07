//
//  LifeOver.h
//  Space Debris
//
//  Created by Globussoft 1 on 7/16/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import "LevelSelectionScene.h"
#import "FriendsViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@class LevelSelectionScene;
@interface LifeOver : SKScene <CBNewsfeedDelegate,ChartboostDelegate>{
    NSInteger min;
    NSInteger sec;
    NSInteger remTime;
    SKLabelNode *timeLeftLabel;
    NSUserDefaults *userDefault;
    UIViewController *rootViewController;
    BOOL isInterstitialFail;
    SKSpriteNode *alertLevel;
    NSInteger isSuccess;
    AppDelegate * appDelegate;
}

@property(nonatomic,strong)  SKSpriteNode *timeLabel;
@property(nonatomic)NSInteger numsec;
@property(nonatomic,retain)NSTimer * timer;
@property(nonatomic,strong)SKSpriteNode *backButton;
@property(nonatomic,weak)SKLabelNode *timerTextCnt;
@property(nonatomic)LevelSelectionScene *levelSelection;
-(id)initWithSize:(CGSize)size;
@property(nonatomic,weak)SKLabelNode *time;

+(SKScene *) scene;
@end
