//
//  GameStartScreen.h
//  Space Debris
//
//  Created by Globussoft 1 on 6/20/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FriendsViewController.h"
#import "AppDelegate.h"

//@class ViewController;

@interface GameStartScreen : SKScene<AVAudioPlayerDelegate,ChartboostDelegate>{

    SKSpriteNode *tutorial;
    SKSpriteNode *ready;
    SKSpriteNode *logo;
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    NSMutableArray *_asteroids;
     NSMutableArray *_asteroids1;
    UIViewController *rootViewController;
   

}
-(id)initWithSize:(CGSize)size ;

@property(nonatomic, assign) CGRect frame1;

@property(nonatomic,strong)  AVAudioPlayer * _musicPlayer;
@property(nonatomic,strong)  SKSpriteNode *connectToFacebook;
@property(nonatomic,strong) SKSpriteNode *lifeBuy;
@property(nonatomic,strong) SKSpriteNode *fbLogout;
@property(nonatomic,strong) SKSpriteNode *showLeaderBoard;
@end
