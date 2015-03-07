//
//  AppDelegate.m
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <Chartboost/Chartboost.h>
#import "GameStatus.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "GameStatus.h"
#import "Flurry.h"


#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceProduct.h"
#import "GAIEcommerceProductAction.h"
#import "GAIEcommercePromotion.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"


#define APP_HANDLED_URL @"App_Handel_Url"
#define ShareToFacebook @"FacebookShare"
#define RequestTOFacebook @"LifeRequest"
#define ReceiveNotification @"REceiveNotification"

@implementation AppDelegate

-(UIViewController *) getRootViewController{
    
    return self.window.rootViewController;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
  
    
    [self checkNetWorkConnection];
    
    BOOL networkConnection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
    
    if (networkConnection) {
        [Flurry startSession:@"V3J9X9QFBX5R48WFHWXJ"];
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-58722207-7"];
    }
    	
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
//Live
//    [Parse setApplicationId:@"HLunaMxOCKHAWV8mx9fjPXVxjQ3p77thjZVdOTnF"                clientKey:@"ntIpq1rCRkhgoNe0HrwepGcMtCr3xfiBFxePcYDt"];     
//    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
       
//testing
       
        [Parse setApplicationId:@"pf5bInfFdMW1dgXqkEagRtCns9kzCAKr1ZQfVhsi" clientKey:@"DKyqyXUvngICsu5g8S2X30BjgLvkDlenXjaqm4js"];
       [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    });
    
            
        NSString *strCheckFirstRun = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstrun"];
    
    if (!strCheckFirstRun) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"strtdate"];
        [GameStatus sharedState].remLife = 10;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstrun"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"levelClear"];
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"life"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"GainLife"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey: ConnectedFacebookUserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self saveinSqlite];
        
    }else{
        if (networkConnection) {
             [self updateLifeInParse];
        }
       
    }
    [self.window makeKeyAndVisible];
       return YES;
    
}

-(void)updateLifeInParse{

    NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    if (fbID && ![fbID isEqualToString:@"Master"]) {

    PFQuery *lifeQuery=[PFQuery queryWithClassName:@"Players"];
        [lifeQuery whereKey:@"PlayerFacebookID" containsString:fbID];
        [lifeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object&&error==nil) {
                NSInteger life=[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
                object[@"Life"] = [NSNumber numberWithInteger:life];
                [object saveInBackground];
                
            }else{
                [self saveLifeINParse];
            }
            
            
        }];
      }

}

-(void)saveLifeINParse{
    NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];

    PFObject *object = [PFObject objectWithClassName:@"Players"];
    object[@"PlayerFacebookID"] = fbID;
    NSInteger life=[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
    object[@"Life"] = [NSNumber numberWithInteger:life];
    object[@"Name"] =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"ConnectedFacebookUserName"]];
    object[@"Device"]=@"iOS";
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"saved sucessfuly");
        }
        if (error) {
            NSLog(@"error to save");
        }
    }];

}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    BOOL fbCheck = [[NSUserDefaults standardUserDefaults] boolForKey:FacebookConnected];
    NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    
    if (fbCheck==YES ) {
        [currentInstallation setObject:fbID forKey:@"facebookId"] ;
    }
    
    [currentInstallation saveInBackground];


}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CheckTimeForLife" object:nil];
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
  
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   
           [self setupLocalNotifications];
    
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidEnterBackground" object:nil];
    
}


- (void)setupLocalNotifications {
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSInteger life=[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
    if (life>=10) {
        return;
    }
    NSInteger gainLife ;
           gainLife=10-life;
  
    NSLog(@"Local notification");
    
    UILocalNotification * localNotification = [[UILocalNotification alloc] init];
    
        // current time plus 9000(2.5 hrs) secs
    NSString *dateStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"firedate"];
    
        
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
    NSDate *now = [formatter1 dateFromString:dateStr];
    NSInteger lifeTime=5*60*gainLife;
    NSDate *dateToFire = [now dateByAddingTimeInterval:lifeTime];
    NSLog(@"time second to fire %ld",(long)lifeTime);
    NSLog(@"now time: %@", now);
    NSLog(@"fire time: %@", dateToFire);
    
    localNotification.fireDate = dateToFire;
    
    localNotification.alertBody =@"% Space Debries Phantom is now refilled with live! Go Explore the Space .  ";
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
        // localNotification.applicationIconBadgeNumber += 1; // increment
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [self checkNetWorkConnection];
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused= YES;
    
     // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     [self checkNetWorkConnection];
    NSString  *isFirstRunning = [[NSUserDefaults standardUserDefaults]objectForKey:@"firstrun"];
    if (isFirstRunning) {
      
            [self compareDate];
        
 [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckTimeForLife" object:nil];

            }else{
        NSLog(@"checking for the first run app delegate and setting start date");
            }
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
    
}

-(void)compareDate {
    
    NSString *strDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"firedate"];
    if (strDate==nil) {
        return;
    }
    NSInteger life=[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
    if (life>=10) {
        return;
    }
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

-(void)getExtraLife :(int)aday andHour:(int)ahour andMin:(int)amin andSec:(int)asec {
    
    int hoursInMin = ahour*60;
    hoursInMin=hoursInMin+amin;
    
    int extralife =hoursInMin/5;
    
//    int totalTime = hoursInMin*60+asec;
    
    
    int rem =amin%5;
    
    int remTimeforLife = rem*60+asec;
    
    remTimeforLife=300-remTimeforLife;
    

       NSInteger life =[[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
   
        if (life+extralife>10) {
            [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"life"];
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"strtdate"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LifeAdded" object:nil];
        }else {
            [[NSUserDefaults standardUserDefaults] setInteger:life+extralife forKey:@"life"];
          [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"strtdate"];
            [[NSUserDefaults standardUserDefaults]synchronize];
      [[NSNotificationCenter defaultCenter]postNotificationName:@"LifeAdded" object:nil];
        }
    
    }


- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    

   NSString *msg=[userInfo valueForKey:@"Message"];
    NSString *type=[userInfo valueForKey:@"Type"];
    NSString *url=[userInfo valueForKey:@"Url"];
    if ([GameStatus sharedState].isGamePlaying==NO) {
        
        [self gotoPushView:type message:msg Url:url];
     
    }
    
    }


-(void)cancelButtonTap:(UIButton *)button{

    messageView.hidden=YES;
    if (messageView) {
        messageView=nil;    }
    
}

-(void)gotoPushView:(NSString *)type message:(NSString *)msg Url:(NSString *)url{

    if ([type isEqualToString:@"1"] || [type isEqualToString:@"2"]||[type isEqualToString:@"3"]||[type isEqualToString:@"4"]) {
        if (!messageView) {
            
            messageView=[[UIView alloc] initWithFrame:CGRectMake(30, 100, 250, 295)];
            messageView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"display.png"]];
            [self.window addSubview:messageView];
            
            UILabel *textMessage=[[UILabel alloc] initWithFrame:CGRectMake(30, 120, 200, 100)];
            textMessage.backgroundColor=[UIColor clearColor];
            textMessage.text=msg;
            textMessage.lineBreakMode=NSLineBreakByCharWrapping;
            textMessage.numberOfLines=0;
            [textMessage setTextColor:[UIColor blueColor]];
            [messageView addSubview:textMessage];
            [textMessage sizeToFit];
            
            UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            cancelButton.frame=CGRectMake(210, 7, 38, 37);
            [cancelButton addTarget:self action:@selector(cancelButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            cancelButton.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"close_big_btn.png"]];
            [messageView addSubview:cancelButton];
            
            UIImageView *messageBox=[[UIImageView alloc] initWithFrame:CGRectMake(88, 40, 70, 70)];
            messageBox.image=[UIImage imageNamed:@"messageBox.png"];
            [messageView addSubview:messageBox];
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame=CGRectMake(50, 210, 150, 50);
            if ([type isEqualToString:@"2"]) {
                button.tag=2;
                [button setTitle:@"Check Now" forState:UIControlStateNormal];
                
            }if ([type isEqualToString:@"1"]) {
                button.tag=1;
                [button setTitle:@"Update Now" forState:UIControlStateNormal];
                
            }
            if ([type isEqualToString:@"3"]) {
                button.tag=3;
                [button setTitle:@"OK" forState:UIControlStateNormal];
            }
            
            if ([type isEqualToString:@"4"]) {
                button.tag=4;
                [button setTitle:@"Accept" forState:UIControlStateNormal];
            }
            
            [button.layer setBorderColor: [[UIColor blueColor] CGColor]];
            [button.layer setBorderWidth: 2.0];
            button.layer.cornerRadius=10.0;
            [button.titleLabel setTextColor:[UIColor blueColor]];
            [button addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor=[UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
            [messageView addSubview:button];
        }
        //    [[AppDelegate sharedAppDelegate]showToastMessage:msg];
    }

}


-(void)openWebview:(UIButton *)button{

    [UIView animateWithDuration:0.5 animations:^{

        messageView.hidden=YES;
        if (messageView) {
            messageView=nil;
        }
       
    }];

    NSURL *url;
//    NSURL URLWithString:urlstr];
    
    
    if (button.tag==2) {
        url=[NSURL URLWithString:@"http://www.globusgames.com/space-debris-phantom-leader-board-ios/"];
        [[UIApplication sharedApplication]openURL:url];

        
    }else if (button.tag==1) {
        url=[NSURL URLWithString:@"https://itunes.apple.com/app/id903882797"];
        [[UIApplication sharedApplication]openURL:url];


    }else if (button.tag==4){
      NSInteger life=  [[NSUserDefaults standardUserDefaults]integerForKey:@"life"];
        [[NSUserDefaults standardUserDefaults]setInteger:life+500 forKey:@"life"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }else{
    
    }
    
   }
-(void)hideHud{

    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
}

#define Facebook delegates

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (BOOL)openSessionWithAllowLoginUI:(NSInteger)isLoginReq{
    self.CurrentValue = isLoginReq;

    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile",@"user_friends",@"publish_actions", nil];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        // Set the active session
    [FBSession setActiveSession:session];
    
    [session openWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                
                if (error==nil) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FacebookConnected];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    FBAccessTokenData *tokenData= session.accessTokenData;
                    
                    NSString *accessToken = tokenData.accessToken;
                    NSLog(@"AccessToken==%@",accessToken);
                    
                    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
                    
                       [self fetchFacebookGameFriends:accessToken];
                    
                    [FBRequestConnection
                     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                       id<FBGraphUser> user,
                                                       NSError *error){
                         
                         NSString *userInfo = @"";
                         userInfo = [userInfo
                                     stringByAppendingString:
                                     [NSString stringWithFormat:@"Name: %@\n\n",
                                      [user objectForKey:@"id"]]];
                         NSLog(@"userinfo = %@",userInfo);
                        
                         NSArray *ary=[userInfo componentsSeparatedByString:@":"];
                         if([ary count]>1){
                             userInfo=[ary objectAtIndex:1];
                             userInfo=[userInfo stringByReplacingOccurrencesOfString:@" " withString:@""];
                             userInfo=[userInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                             NSLog(@"sender id=%@",userInfo);
                             
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FacebookConnected];
                [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:ConnectedFacebookUserID];
                [[NSUserDefaults standardUserDefaults]synchronize];
                             [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
                                 if (error) {
                                         // Handle error
                                 }
                                 
                                 else {
                                     self.userName = [FBuser name];
                                     [[NSUserDefaults standardUserDefaults] setObject:self.userName  forKey:@"ConnectedFacebookUserName"];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     NSLog(@"username is %@",self.userName);
                                     
                                    
                                 }
                             }];
                         }
                     }];
                    
                 }
                else{
                    
                    NSLog(@"Session not open==%@",error);
                    
                }
                
        }];

    return YES;
}



-(BOOL) openSessionWithLoginUI:(NSInteger)value withParams: (NSDictionary *)dict isLife:(NSString *)life{
    [self retriveFromSQL];
    isSessionOpen=NO;
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile",@"user_friends",@"publish_actions", nil];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        // Set the active session
    [FBSession setActiveSession:session];
    

    ms_friendCache = NULL;
    
    [session openWithBehavior:FBSessionLoginBehaviorWithNoFallbackToWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                 
                if (error==nil) {
                    
               
                    [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];
                    FBAccessTokenData *tokenData= session.accessTokenData;
                    
                    NSString *accessToken = tokenData.accessToken;
                    NSLog(@"AccessToken==%@",accessToken);
                    
                    
                    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
                    if (accessToken && value!=8) {
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                        [self fetchFacebookGameFriends:accessToken];
                    }
                    
                    if (value==1) {
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                        [self shareOnFacebookWithParams:dict islife:life];
                    }
                    else if (value == 2){
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                     [self sendRequestToFriends:self.friendsList];
                    }
                    else if(value == 8){
                        
//                        [self findFBIDClearedLevel];
                        
                    }
                    else if(value == 3){
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                        [self storyPostwithDictionary:dict];
                    }

                    else if(value == 0){
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                        [self retriveAppFriends];
                    }
                    else{
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                        
                        NSLog(@"Unknown Value");
                    
                    }
                    
                         if(value == 8){
                             
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> user,NSError *error){
            
            
                                  NSLog(@"User = %@",user);
            
                                  NSString *userName = [NSString stringWithFormat:@"%@",[user objectForKey:@"name"]];
                                  NSString *userID = [NSString stringWithFormat:@"%@",[user objectForKey:@"id"]];
            
            if (accessToken) {
                
          [[NSNotificationCenter defaultCenter] postNotificationName:@"openSession" object:nil];
                [self fetchFacebookGameFriends:accessToken];

                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey :FacebookConnected];
                                  [[NSUserDefaults standardUserDefaults] setObject:userID forKey:ConnectedFacebookUserID];
                                  [[NSUserDefaults standardUserDefaults] setObject:userName  forKey:@"ConnectedFacebookUserName"];
                                  
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                
                
                
        [self performSelectorOnMainThread:@selector(synchronize) withObject:nil waitUntilDone:YES];
               
                
//                [self findFBIDClearedLevel];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                
                
                BOOL fbCheck = [[NSUserDefaults standardUserDefaults] boolForKey:FacebookConnected];
                NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
                
                if (fbCheck==YES ) {
                    [currentInstallation setObject:fbID forKey:@"facebookId"] ;
                    
                }
                
                [currentInstallation saveInBackground];
               
            }else{
                
                [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FacebookConnected];
                [[NSUserDefaults standardUserDefaults]synchronize];
                isSessionOpen=NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"openSessionCancel" object:nil];


            }
                             
           }];
                       
                         
         }
                    
    }
        else{
                    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                    NSLog(@"Session not open==%@",error);
                    isSessionOpen=NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openSessionCancel" object:nil];
           }
                
                    // Respond to session state changes,
                    // ex: updating the view
            }];
    
    return isSessionOpen;
}


-(void)findFBIDClearedLevel{
    BOOL netWorkConnection=[[NSUserDefaults standardUserDefaults]boolForKey:@"ConnectionAvilable"];
    
    if (netWorkConnection==YES){
        
        NSString *fbID = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
        if (fbID) {
            PFQuery * query=[PFQuery queryWithClassName:ParseScoreTableName];
            [query whereKey:@"PlayerFacebookID" equalTo:fbID];
            
            [query orderByDescending:@"Level"];
//            PFObject *object= [query getFirstObject];
                   [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            //
            NSNumber *num=object[@"Level"];
                       [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
            int levelClear=[num intValue]+ 1;
            [[NSUserDefaults standardUserDefaults] setInteger:levelClear forKey:@"levelClear"];
            
           }];
            
        }
        
    }
    
}


#pragma mark -
-(void) shareOnFacebookWithParams:(NSDictionary *)params islife:(NSString *)life{
    
    
    
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultUrl, NSError *error){
        
        if (error) {
            NSLog(@"Error to post on facebook = %@", [error localizedDescription]);
        }
        else{
            
           
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
                    if ([life isEqualToString:@"Yes"]) {
                        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"life"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Space Debris Phantom refilled with lives" message:@"Enjoy the game" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"strtdate"];


                    }
                    NSLog(@"posted on wall");
                }
            }//End Else Block Result Check
        }
    }];
}


-(void) sendRequestToFriends:(NSMutableString *)params{
    
//    NSMutableString *taggedFriend=[params valueForKey:@"tags"];
//    NSInteger count=[[params valueForKey:@"count"] integerValue];
    if (params==nil) {
        params= self.friendsList;
    }
    [[AppDelegate sharedAppDelegate]showHUDLoadingView:@""];
    NSMutableDictionary<FBGraphObject> *object =
    [FBGraphObject openGraphObjectForPostWithType:@"sdphantom:life"
                                            title:@""
                                            image:@"fbstaging://graph.facebook.com/staging_resources/MDExNDUzNzA0OTM0OTAyODEwOjQxMjYzOTIzOA=="
                                              url:@"https://itunes.apple.com/app/id903882797"
                                      description:@"Hi Friends, Please join me in Space Debris Phatom and help me get past the debris in deep blue fathomless sea of stars."];
     
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject openGraphActionForPost];
    action[@"tags"]=params;
   action[@"life"]=object;

    
    [FBRequestConnection startForPostWithGraphPath:@"me/sdphantom:request"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView ];

                                     if (!error) {
        [[NSUserDefaults standardUserDefaults]setInteger:self.friendsCount/5 forKey:@"life"];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"strtdate"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"postSuccess" object:nil];
                                     }else{
                                         NSLog(@"error %@",error.description);
         [[AppDelegate sharedAppDelegate]showToastMessage:@"Error on posting to facebook.Please try again"];
        [[AppDelegate sharedAppDelegate]hideHUDLoadingView ];
         
                                     }
                                     // handle the result
                                 }];
    
    }


-(void) fetchFacebookGameFriends:(NSString *)accessToken{
    NSString *query =
    @"SELECT uid, name, pic_small FROM user WHERE is_app_user = 1 and uid IN "
    @"(SELECT uid2 FROM friend WHERE uid1 = me() )";
    
    NSDictionary *queryParam = @{ @"q": query, @"access_token":accessToken };
        // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"parameters:queryParam HTTPMethod:@"GET"completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else {
                // NSLog(@"Result: %@", result);
            
            NSArray *friendInfo = (NSArray *) result[@"data"];
            
            NSLog(@"Array Count==%lu",(unsigned long)[friendInfo count]);
            
            NSLog(@"\n\nArray==%@",friendInfo);
            
            NSMutableArray *frndsarray = [[NSMutableArray alloc] init];
            NSMutableArray *frndNamearray=[[NSMutableArray alloc] init];
            for (int i =0; i<friendInfo.count; i++) {
                NSDictionary *dict = [friendInfo objectAtIndex:i];
                NSString *fbID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"uid"]];
                NSString *fbName =[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                [frndsarray addObject:fbID];
                [frndNamearray addObject:fbName];
                
            }//End For Loop
            
            [[NSUserDefaults standardUserDefaults] setObject:frndsarray forKey:FacebookGameFrindes];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSUserDefaults standardUserDefaults]setObject:frndNamearray forKey:@"name"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        
            FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/invitable_friends?fields=name,picture,id"];
            
            [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSArray *invite_friendInfo = (NSArray *) result[@"data"];
                
                //                NSLog(@"Array Count==%lu",(unsigned long)[invite_friendInfo count]);
                //                NSLog(@"ARRAY = %@",invite_friendInfo);
                //========================
                NSMutableArray *inviteFrndsAry = [[NSMutableArray alloc] init];
                
                for (int i =0; i<invite_friendInfo.count; i++) {
                    NSDictionary *dict = [invite_friendInfo objectAtIndex:i];
                    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
                    
                    NSString *aid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                    //NSLog(@"aid = %@",aid);
                    [aDict setObject:aid forKey:@"uid"];
                    NSString *name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                    [aDict setObject:name forKey:@"name"];
                    NSDictionary *secDict = [[dict objectForKey:@"picture"] objectForKey:@"data"];
                    NSString *picUrl = [NSString stringWithFormat:@"%@",[secDict objectForKey:@"url"]];
                    [aDict setObject:picUrl forKey:@"pic_small"];
                    
                    [inviteFrndsAry addObject:aDict];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:inviteFrndsAry forKey:FacebookInviteFriends];
                
                NSArray *allFrndsArray = [friendInfo arrayByAddingObjectsFromArray:inviteFrndsAry];
                NSLog(@"All Friends Array = %@",allFrndsArray);
                NSMutableArray *tagbl_FrndAry=[[NSMutableArray alloc] init];
                [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                             parameters:nil
                                             HTTPMethod:@"GET"
                                      completionHandler:^(
                                                          FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error
                                                          ) {
                                          NSArray *arr=[result valueForKey:@"data"];
                                          
                                for (NSDictionary *dict in arr) {
                                        
                                            NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
                                            
                                            NSString *aid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                                            //NSLog(@"aid = %@",aid);
                                            [aDict setObject:aid forKey:@"uid"];
                                            NSString *name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                                            [aDict setObject:name forKey:@"name"];
                                            NSDictionary *secDict = [[dict objectForKey:@"picture"] objectForKey:@"data"];
                                            NSString *picUrl = [NSString stringWithFormat:@"%@",[secDict objectForKey:@"url"]];
                                            [aDict setObject:picUrl forKey:@"pic_small"];
                                            
                                            [tagbl_FrndAry addObject:aDict];
                                    
                                    if (tagbl_FrndAry.count==arr.count) {
//                                        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                                    }

                                        }
                                          
                                           [[NSUserDefaults standardUserDefaults] setObject:tagbl_FrndAry forKey:FacebookAllFriends];
                                      }];

                 [[NSUserDefaults standardUserDefaults] setObject:tagbl_FrndAry forKey:FacebookAllFriends];
                 NSLog(@"All Friends Array = %@",tagbl_FrndAry);
//                if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(displayFacebookFriendsList)]) {
//                    
//                    [self.delegate displayFacebookFriendsList];
//                }
            }];
        
        }
    }];
}

-(void) retriveAppFriends{
    
    NSMutableArray *tagbl_FrndAry=[[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSArray *arr=[result valueForKey:@"data"];
                              
                              for (NSDictionary *dict in arr) {
                                  
                                  NSMutableDictionary *aDict = [[NSMutableDictionary alloc] init];
                                  
                                  NSString *aid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                                  //NSLog(@"aid = %@",aid);
                                  [aDict setObject:aid forKey:@"uid"];
                                  NSString *name = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                                  [aDict setObject:name forKey:@"name"];
                                  NSDictionary *secDict = [[dict objectForKey:@"picture"] objectForKey:@"data"];
                                  NSString *picUrl = [NSString stringWithFormat:@"%@",[secDict objectForKey:@"url"]];
                                  [aDict setObject:picUrl forKey:@"pic_small"];
                                  
                                  [tagbl_FrndAry addObject:aDict];
                                  
                              }
                              
                              [[NSUserDefaults standardUserDefaults] setObject:tagbl_FrndAry forKey:FacebookAllFriends];
                          }];
    
    [[NSUserDefaults standardUserDefaults] setObject:tagbl_FrndAry forKey:FacebookAllFriends];
    NSLog(@"All Friends Array = %@",tagbl_FrndAry);
    
}

#pragma mark -
-(void) storyPostwithDictionary:(NSDictionary *)dict{
    
    //http://www.screencast.com/t/TbZbFgTHJpeR
    
    NSString *description = [NSString stringWithFormat:@"%@",[dict objectForKey:FacebookDescription]];
    NSString *title = [NSString stringWithFormat:@"%@",[dict objectForKey:FacebookTitle]];
    
    NSString *type = [NSString stringWithFormat:@"%@",[dict objectForKey:FacebookType]];
    
    NSString *actionType = [NSString stringWithFormat:@"/me/sdphantom:%@",[dict objectForKey:FacebookActionType]];
    NSLog(@"Type = %@", type);
    NSLog(@"Action  =%@",actionType);
 
    
    //fbstaging://graph.facebook.com/staging_resources/MDExNDQyNjIzMzQyNjc3NjM2OjUxMDY4MTkwNg==
    
    id<FBGraphObject> object =
    [FBGraphObject openGraphObjectForPostWithType:[NSString stringWithFormat:@"sdphantom:%@",type] title:title image:@"fbstaging://graph.facebook.com/staging_resources/MDExNDUzNzA0OTM0OTAyODEwOjQxMjYzOTIzOA==" url:@"https://itunes.apple.com/app/id903882797" description:description];
    
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [action setObject:object forKey:type];
    
    // create action referencing user owned object
    [FBRequestConnection startForPostWithGraphPath:actionType graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSLog(@"OG story posted, story id: %@", [result objectForKey:@"id"]);
//           [[[UIAlertView alloc] initWithTitle:@"OG story posted" message:@"Check your Facebook profile or activity log to see the story."
//                                    delegate:self
//                             cancelButtonTitle:@"OK!"
//                             otherButtonTitles:nil] show];
        } else {
            // An error occurred
            NSLog(@"Encountered an error posting to Open Graph: %@", error);
        }
    }];
    
    
    // }
    // }];
    
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
        // attempt to extract a token from the url
        //return [FBSession.activeSession handleOpenURL:url];
    
    NSLog(@"Url %@",url);
        // attempt to extract a token from the url
    
    [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        NSString *accessToken = call.accessTokenData.accessToken;
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"Facebook Access Token"];
        NSLog(@"App Link Data = %@",call.appLinkData);
        NSLog(@"call == %@",call);
        if (call.appLinkData && call.appLinkData.targetURL) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FacebookRequestNotification object:call.appLinkData.targetURL];
        }
        
    }];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"Url== %@", url);
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)checkNetWorkConnection{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    BOOL netWorkConnection;
    if(status == NotReachable)
    {
        netWorkConnection=NO;
    }
    else if (status == ReachableViaWiFi){
     netWorkConnection=YES;
    }else if (status==ReachableViaWWAN){
        netWorkConnection=YES;

    }else{
      netWorkConnection=NO;
    }
    
   [[NSUserDefaults standardUserDefaults] setBool:netWorkConnection forKey:@"ConnectionAvilable"];

}


#pragma mark-
#pragma mark - MBProgress Hud

+(AppDelegate *)sharedAppDelegate{
    
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];

}

-(void) showHUDLoadingView:(NSString *)strTitle
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    //HUD.delegate = self;
    //HUD.labelText = [strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    HUD.detailsLabelText=[strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [HUD show:YES];
}

-(void) hideHUDLoadingView
{
    [HUD removeFromSuperview];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window
                                              animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0];
}



#pragma mark Sqlite DB and Retrive--
-(void)saveinSqlite
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
        //NSLog(@"%@",paths);
        // Check to see if the database file already exists
    
    
    /*if (databaseAlreadyExists == YES) {
     return;
     }*/
    
        // Open the database and store the handle as a data member
    if (sqlite3_open([databasePath UTF8String], &_databaseHandle) == SQLITE_OK)
    {
            // Create the database if it doesn't yet exists in the file system
        
        
            // Create the PERSON table
        const char *sqlStatement = "CREATE TABLE  GameScoreFinal (ID INTEGER PRIMARY KEY AUTOINCREMENT, Level TEXT, Score TEXT,PlayerFacebookID TEXT,Name TEXT)";
        /*NSString *insert=[NSString stringWithFormat:@"insert into person(id,firsrtname) VALUES(\"%@\",\"%@\")",1,"hunny"];*/
        /*  const char *insert="INSERT INTO PERSON (FIRSTNAME, LASTNAME, BIRTHDAY) VALUES ('""1'""'hunny'""'singh'""'1992-08-14')";*/
        char *error;
        if (sqlite3_exec(_databaseHandle, sqlStatement, NULL, NULL, &error) == SQLITE_OK)
        {
            NSLog(@"table created");
                // Create the ADDRESS table with foreign key to the PERSON table
            
            NSLog(@"Database and tables created.");
        }
        else
        {
            NSLog(@"````Error: %s", error);
        }
    }
    
    
}


-(void)synchronize
{
    
    PFQuery * queryUser=[PFQuery queryWithClassName:ParseScoreTableName];
    NSLog(@"Connected fb user id %@",[[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID]);
   NSString *fbUsername= [[NSUserDefaults standardUserDefaults] objectForKey:@"ConnectedFacebookUserName"];
    [queryUser whereKey:@"PlayerFacebookID" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID]];
    [queryUser orderByDescending:@"Level"];
//    dispatch_async(dispatch_get_global_queue(0,0),^{
      
    [queryUser findObjectsInBackgroundWithBlock:^(NSArray *temp, NSError *error) {
            
        [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
        if([temp count]>0)
        {
                //if data is present
            for(int i=0;i<[temp count];i++)
            {
                PFObject * objUserData=[temp objectAtIndex:i];
                NSLog(@"Local data count %lu",(unsigned long)[localData count]);
                
                for(int j=0;j<[localData count];j++)
                {
                    
                    NSDictionary * temp=[localData objectAtIndex:j];
                    [temp objectForKey:@"Score"];
                    if([objUserData[@"Level"] integerValue]==[[temp objectForKey:@"Level"] integerValue])
                    {
                        if([objUserData[@"Score"] integerValue]<[[temp objectForKey:@"Score"] integerValue])
                        {
                            objUserData[@"Score"]=[NSNumber numberWithInteger:[[temp objectForKey:@"Score"] integerValue]];
                            objUserData[@"Name"]=fbUsername;
                            
                            [objUserData saveInBackground];
                        }//if
                        [localData removeObjectAtIndex:j];
                    }//if
                    
                }//for
            }//for
            for (int i=0; i<[localData count]; i++) {
                NSDictionary * localtemp=[localData objectAtIndex:i];
                PFObject * objNewData=[PFObject objectWithClassName:ParseScoreTableName];
                objNewData[@"Level"]=[NSNumber numberWithInt:[[localtemp objectForKey:@"Level"] intValue]];
                objNewData[@"Score"]=[NSNumber numberWithInt:[[localtemp objectForKey:@"Score"] intValue]];
                objNewData[@"PlayerFacebookID"]=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
//                NSString * name=[localtemp objectForKey:@"Name"];
                objNewData[@"Name"]=fbUsername;
                
                [objNewData saveInBackground];

            }
                //check highest level
            if([localData count]>0)
            {
                NSDictionary * localtemp=[localData objectAtIndex:0];
                PFObject * objUserData=[temp objectAtIndex:0];
                if([objUserData[@"Level"] integerValue]>
                   [[localtemp objectForKey:@"Level"] integerValue])
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:([objUserData[@"Level"] intValue]+1) forKey:@"levelClear"];
                    
                    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setInteger:([[localtemp objectForKey:@"Level"] integerValue]+1)forKey:@"levelClear"];
                    
                     [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                }
            }
            else
            {//if local data is not there make parse data highest.
                [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                PFObject * objUserData=[temp objectAtIndex:0];
                [[NSUserDefaults standardUserDefaults] setInteger:([objUserData[@"Level"] intValue]+1)forKey:@"levelClear"];
            }
        }//if
        else
        {
                //if data is not there
            if(master)
            {
                for(int i=0;i<[localData count];i++)
                {
                    PFObject * objUserData=[PFObject objectWithClassName:@"GameScore"];
                        //-------------------
                    NSDictionary * localtemp=[localData objectAtIndex:i];
                    ;
                    [localtemp objectForKey:@"Score"];
                    objUserData[@"Level"]=[NSNumber numberWithInt:[[localtemp objectForKey:@"Level"] intValue]];
                    objUserData[@"Score"]=[NSNumber numberWithInt:[[localtemp objectForKey:@"Score"] intValue]];
                    objUserData[@"PlayerFacebookID"]=[[NSUserDefaults standardUserDefaults]objectForKey:ConnectedFacebookUserID];
                    NSString * name=[localtemp objectForKey:@"Name"];
                    if ([name  isEqualToString:@"(null)"]) {
                        objUserData[@"Name"]=fbUsername;
                    }
                    else
                    {
                        objUserData[@"Name"]=fbUsername;
                    }
                    
                        //----------------------
                    BOOL result=[objUserData save];
                    NSLog(@"result %d",result);
                }
                 [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                [self deleteLocalDataBase];
            }
            else
            {
                    //if not master
                [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"levelClear"];
            }
            
            [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

        }
        
    }];
    [self deleteLocalDataBase];
//    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];

    NSLog(@"Local Data %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"LocalScoredDictionary"]);
    
}


-(void)deleteLocalDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"-------%@",paths);
    sqlite3_stmt *stmt=nil;
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
    
    const char *sql = "Delete from GameScoreFinal";
    
    
    if(sqlite3_open([databasePath UTF8String], &_databaseHandle)!=SQLITE_OK)
        NSLog(@"error to open");
    if(sqlite3_prepare_v2(_databaseHandle, sql, -1, &stmt, NULL)!=SQLITE_OK)
    {
        NSLog(@"error to prepare");
        NSLog(@"%s Prepare failure '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(_databaseHandle), sqlite3_errcode(_databaseHandle));
        
        
    }
    if(sqlite3_step(stmt)==SQLITE_DONE)
    {
        NSLog(@"Delete successfully");
    }
    else
    {
        NSLog(@"Delete not successfully");
        
    }
    sqlite3_finalize(stmt);
    sqlite3_close(_databaseHandle);
    
    
}



-(void)retriveFromSQL
{
    localData=[[NSMutableArray alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"GameScoreDb.sqlite"];
    NSLog(@"Connected fb user id %@",[[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID]);
    
    // Check to see if the database file already exists
    NSString * connectedFBid=[[NSUserDefaults standardUserDefaults] objectForKey:ConnectedFacebookUserID];
    NSString *query = [NSString stringWithFormat:@"select * from GameScoreFinal where PlayerFacebookID = \"%@\" ORDER BY Level Desc",connectedFBid];
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
            char *PlayerFacebookID = (char *) sqlite3_column_text(stmt,3);
            char *name = (char *)  sqlite3_column_text(stmt,4);
            NSString *strLevel= [NSString  stringWithUTF8String:level];
            
            NSString *strScore  = [NSString stringWithUTF8String:score];
            NSString *playerFBid  = [NSString stringWithUTF8String:PlayerFacebookID];
            NSString *Name = [NSString stringWithUTF8String:name];
            NSLog(@"player FB ID %@",playerFBid);
            if([playerFBid isEqualToString:@"Master"])
            {
                master=TRUE;
            }
            NSLog(@"Level %@ and Score %@ ",strLevel,strScore);
            NSString * keyLevel=strLevel;
            NSString * keyScore=strScore;
            NSMutableDictionary * temp=[[NSMutableDictionary alloc]init];
            [temp setObject:keyLevel forKey:@"Level"];
            [temp setObject:keyScore forKey:@"Score"];
            [temp setObject:playerFBid forKey:@"PlayerFacebookID"];
            [temp setObject:Name forKey:@"Name"];
            [localData addObject:temp];
        }
    }
    @catch(NSException *e)
    {
        NSLog(@"%@",e);
    }
    
    
}
- (void) dealloc
{
        // If you don't remove yourself as an observer, the Notification Center
        // will continue to try and send notification objects to the deallocated
        // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}
@end
