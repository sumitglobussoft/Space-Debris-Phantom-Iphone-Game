//
//  AppDelegate.h
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <Chartboost/CBNewsfeed.h>
#import <Chartboost/Chartboost.h>
#import "MBProgressHUD.h"
#import "Flurry.h"
#import <sqlite3.h>
////@protocol AppDelegateDelegate <NSObject>
//
//@optional
//-(void)displayFacebookFriendsList;
//-(void) hideFacebookFriendsList;
//-(void) storyPostUpdate;
//@end


@interface AppDelegate : NSObject <UIApplicationDelegate,ChartboostDelegate,CBNewsfeedDelegate> {
    FBFrictionlessRecipientCache* ms_friendCache;
    MBProgressHUD *HUD;
    
    sqlite3 *_databaseHandle;
     BOOL master;
//    UIWindow *window;
    UIView *messageView;
    NSMutableArray * localData;
     BOOL isSessionOpen;
}

//@property (nonatomic, strong) id <AppDelegateDelegate> delegate;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) NSInteger CurrentValue;
@property(nonatomic,strong)NSString *userName;
@property (nonatomic, strong) NSDictionary *openGraphDict;
@property(nonatomic,strong)NSMutableString *friendsList;
@property(nonatomic)NSInteger friendsCount;
-(UIViewController *) getRootViewController;

- (BOOL)openSessionWithAllowLoginUI:(NSInteger)isLoginReq;

-(BOOL) openSessionWithLoginUI:(NSInteger)value withParams: (NSDictionary *)dict isLife:(NSString *)life;

-(void) shareOnFacebookWithParams:(NSDictionary *)params islife:(NSString *)life;

-(void) sendRequestToFriends:(NSMutableString *)params;

-(void) storyPostwithDictionary:(NSDictionary *)dict;

-(void) showHUDLoadingView:(NSString *)strTitle;
-(void) hideHUDLoadingView;
+(AppDelegate *)sharedAppDelegate;
-(void)showToastMessage:(NSString *)message;

@end
