//
//  ViewController.h
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
//#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GameOverScene.h"
#import "GameStartScreen.h"
#import "GameStartScreen.h"


@import GoogleMobileAds;

@interface ViewController : UIViewController <UIScrollViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate>{
    UIViewController *rootViewController ;
}

//@property (strong, nonatomic) ADBannerView *bannerView;

@property(nonatomic, weak)UIView *clearContentView;
@property(nonatomic, strong) GADBannerView *bannerView;

@property(nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, strong) NSString *senderID;
@property (nonatomic, retain) UIView *displayRequestView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, retain) NSString *senderName;
@property (nonatomic, retain) NSString *currentUserName;

@property (nonatomic, strong) SKView * skView;
//+(ViewController *)sharedObject;
-(void)showBannerAdd;
-(void)hideBannerAdd;
@end
