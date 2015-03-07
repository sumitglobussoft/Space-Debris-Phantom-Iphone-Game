//
//  ViewController.m
//  Space Debris!
//
//  Copyright (c) 2014 Giorgio Minissale. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "LevelSelectionScene.h"
#import "GameOverScene.h"
#import "GameStartScreen.h"
#import "SBJson.h"
#import "GameStatus.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static NSString * kViewTransformChanged = @"view transform changed";

////@property(nonatomic, weak)LevelSelectionScene *scene;
//@property(nonatomic, weak)GameStartScreen *scene;
////@property(nonatomic, weak)GameOverScene *scene;
//}
//@end
@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
     
        // Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    BOOL connection=[[NSUserDefaults standardUserDefaults] boolForKey:@"ConnectionAvilable"];
    if (connection==YES) {

        
            // code that generates exception
            self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
            self.bannerView.delegate=self;
            //Testing
       // self.bannerView.adUnitID = @"ca-app-pub-2153224671936897/9351709766";
            //Live
   self.bannerView.adUnitID = @"ca-app-pub-7881880964352996/5159543266";
            
          self.bannerView.hidden=YES;
            self.bannerView.rootViewController = self;
            [self.view addSubview:self.bannerView];
            
               //Live
            //    self.bannerView.adUnitID = @"ca-app-pub-7881880964352996/3543209267";
            GADRequest *request = [GADRequest request];
//            request.testDevices = @[ GAD_SIMULATOR_ID ];
            [self.bannerView loadRequest:request];
 
      }
    
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNotification:) name:FacebookRequestNotification object:nil];
  // Configure the view.
  self.skView = (SKView *)self.view;
  self.skView.showsFPS = NO;
  self.skView.showsNodeCount = NO;
  
   GameStartScreen *scene = [[GameStartScreen alloc] initWithSize:self.skView.bounds.size ];
   scene.scaleMode = SKSceneScaleModeAspectFill;
    
  // Present the scene.
 [self.skView presentScene:scene];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadInterstitial) name:@"adMobInterstitial" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showBannerAdd) name:@"adMobBanner" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideBannerAdd) name:@"hideAdmobBanner" object:nil];
    
    self.interstitial = [self createAndLoadInterstitial];
    
    }

- (void) adView: (GADBannerView*) view didFailToReceiveAdWithError: (GADRequestError*) error{
    NSLog(@"did fail to receive");
}

- (void) adViewDidReceiveAd: (GADBannerView*) view{
//    NSLog(@"add received");
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"adMobInterstitial" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"adMobBanner" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"hideAdmobBanner" object:nil];

    
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }

}

-(void)showBannerAdd{
    
    
      self.bannerView.hidden=NO;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];


}

-(void)hideBannerAdd{
self.bannerView.hidden=YES;
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}


#pragma mark -
-(void) checkNotification:(NSNotification *)notify{
    
    NSLog(@"Url = %@",notify.object);
    
    NSURL *targetURL = notify.object;
    
    NSRange range = [targetURL.query rangeOfString:@"notif" options:NSCaseInsensitiveSearch];
    
    // If the url's query contains 'notif', we know it's coming from a notification - let's process it
    if(targetURL.query && range.location != NSNotFound)
    {
        [self processRequest:targetURL];
    }
}

-(void) processRequest:(NSURL *)targetURL{
    // Extract the notification id
    
    NSArray *pairs = [targetURL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [queryParams setObject:val forKey:[kv objectAtIndex:0]];
    }
    
    NSString *requestIDsString = [queryParams objectForKey:@"request_ids"];
    NSArray *requestIDs = [requestIDsString componentsSeparatedByString:@","];
//    [self.gameStart setUserInteractionEnabled: NO];
    
    if (!self.displayRequestView) {
        self.displayRequestView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.displayRequestView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popupbg.png" ]];
        self.displayRequestView.alpha = 0.9f;
        [self.view addSubview:self.displayRequestView];
        self.displayRequestView.userInteractionEnabled = YES;
    }
    else{
        self.displayRequestView.hidden = NO;
    }
        
    FBRequest *req = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:[requestIDs lastObject]];
    [req startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        NSLog(@"Result== %@",result);
        NSLog(@"errror == %@",error);
        if (!error)
        {
            NSLog(@"Display life request UI");
            
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:result];
            NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
            NSLog(@"message %@",message);
            if ([message isEqualToString:@"sending life request"]) {
                
                [self displayLifeRequestUI:dict];
            }
            else if([message isEqualToString:@"sending extra life"]){
                
                [self lifeAcceptUIWithDictionary:dict];
            }
            else{
                NSLog(@"Unknown request");
//                [self.gameStart setUserInteractionEnabled: YES];
                self.displayRequestView.hidden = NO;
            }
        }
        else{
            
            NSLog(@"Error == %@",error.localizedDescription);
//            [self.gameStart setUserInteractionEnabled:YES];
            self.displayRequestView.hidden = NO;
            
        }
    }];
    
}
#pragma mark-
-(void) lifeAcceptUIWithDictionary:(NSDictionary *)result{
    
    NSDictionary *fromDataDict = [result objectForKey:@"from"];
    NSDictionary *toDict = [result objectForKey:@"to"];
    
    NSString *sendername = [NSString stringWithFormat:@"%@",[fromDataDict objectForKey:@"name"]];
    NSLog(@"from = %@",sendername);
    self.senderName = sendername;
    
    NSString *receiverName = [NSString stringWithFormat:@"%@",[toDict objectForKey:@"name"]];
    self.currentUserName = receiverName;
    
    
    NSString *senderID = [NSString stringWithFormat:@"%@",[fromDataDict objectForKey:@"id"]];
    self.senderID = senderID;
    NSLog(@"url == http://graph.facebook.com/%@",senderID);
    [self createUI:sendername];
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.senderID]] placeholderImage:[UIImage imageNamed:@"icon-120.png"]];
    
    NSArray * arr = [sendername componentsSeparatedByString:@" "];
    NSLog(@"Array values are : %@",arr);
    NSLog(@"Array [0] is :%@",arr[0]);
    self.nameLabel.text = [NSString stringWithFormat:@"%@",arr[0]];
    self.messageLabel.text = [NSString stringWithFormat:@"sent you extra life"];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"yes.png"] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(lifeAcceptButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.displayRequestView.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.containerView.frame = CGRectMake(30, 105, 255, 278);
    }];
}
-(void)lifeAcceptButtonAction:(id)sender{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int lifeUserDefault = (int)[userDefault integerForKey:@"life"];
    //NSLog(@"Life Before added -==- %d",lifeUserDefault);
    NSString *title = [NSString stringWithFormat:@"Thank you %@ for extra life",self.senderName];
    NSString *description = [NSString stringWithFormat:@"%@ got one extra life gifted by %@",self.currentUserName,self.senderName];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"life",FacebookType,title,FacebookTitle,description,FacebookDescription,@"say",FacebookActionType, nil];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate storyPostwithDictionary:dict];
    
    if (lifeUserDefault<=4) {
        lifeUserDefault++;
        [userDefault setInteger:lifeUserDefault forKey:@"life"];
        // NSLog(@"Life After added -==- %d",lifeUserDefault);
        [userDefault synchronize];
        
     }
    [self cancelButtonClicked:nil];
}

#pragma mark -
-(void) displayLifeRequestUI:(NSDictionary *)result{
    
    NSDictionary *fromDataDict = [result objectForKey:@"from"];
    NSDictionary *toDict = [result objectForKey:@"to"];
    
    NSString *sendername = [NSString stringWithFormat:@"%@",[fromDataDict objectForKey:@"name"]];
    NSLog(@"from = %@",sendername);
    self.senderName = sendername;
    
    NSString *receiverName = [NSString stringWithFormat:@"%@",[toDict objectForKey:@"name"]];
    self.currentUserName = receiverName;
    
    
    NSString *senderID = [NSString stringWithFormat:@"%@",[fromDataDict objectForKey:@"id"]];
    self.senderID = senderID;
    NSLog(@"url == http://graph.facebook.com/%@",senderID);
    //    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@",senderID]]];
    //    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"Response = %@",response);
    
    [self createUI:sendername];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.senderID]] placeholderImage:[UIImage imageNamed:@"icon-120.png"]];
    
    NSArray * arr = [sendername componentsSeparatedByString:@" "];
    NSLog(@"Array values are : %@",arr);
    NSLog(@"Array [0] is :%@",arr[0]);
    
    self.nameLabel.text = [NSString stringWithFormat:@"Help %@",arr[0]];
    self.messageLabel.text = [NSString stringWithFormat:@"send extra life"];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"send1.png"] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.displayRequestView.hidden = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.containerView.frame = CGRectMake(30, 105, 255, 278);
    }];
}
-(void) createUI:(NSString *)senderName{
    
    if (!self.containerView) {
          
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(30, -300, 255, 278)];
        //self.containerView.userInteractionEnabled = YES;
        self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Score.png"]];
        [self.view addSubview:self.containerView];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width/2-25,20, 50, 50)];
        self.profileImageView.backgroundColor  = [UIColor clearColor];
        [self.containerView addSubview:self.profileImageView];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 250, 60)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.font = [UIFont fontWithName:@"TerrorPro" size:25];
        self.nameLabel.textColor = [UIColor colorWithRed:(CGFloat)132/255 green:(CGFloat)98/255 blue:(CGFloat)166/255 alpha:1.0f];
        self.nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.containerView addSubview:self.nameLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 95, 250, 60)];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.font = [UIFont fontWithName:@"TerrorPro" size:25];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.containerView addSubview:self.messageLabel];
        
        
        //=
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(20, 200, 100, 45);
        //self.cancelButton.titleLabel.textColor = [UIColor whiteColor];
        //[self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel1.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.cancelButton];
        //=
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame = CGRectMake(140, 200, 100, 45);
        //        self.sendButton.titleLabel.textColor = [UIColor whiteColor];
        //        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        
        [self.containerView addSubview:self.sendButton];
    }
//    else{
//        self.con.hidden = NO;
//    }
    
}

-(void) sendButtonClicked:(id)sender{
    
    SBJsonWriter *jsonWriter = [SBJsonWriter new];
    self.currentUserName= [[NSUserDefaults standardUserDefaults] objectForKey:@"ConnectedFacebookUserName"];

    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"got extra life life"], @"message", nil];
    NSString *lifeReq = [jsonWriter stringWithObject:challenge];
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:self.senderID, @"to",lifeReq, @"data",@"sending extra life",@"message",@"Send Live",@"Title",nil];
    
    NSString *title = [NSString stringWithFormat:@"i sent extra life to %@",self.senderName];
    NSString *des = [NSString stringWithFormat:@"Now %@ has one extra life gifted by %@",self.senderName, self.currentUserName];
    NSDictionary *storyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"life",FacebookType,title,FacebookTitle,des,FacebookDescription,@"send",FacebookActionType, nil];
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.openGraphDict = storyDict;
    
    if (!FBSession.activeSession.isOpen) {
        
        [appDelegate openSessionWithLoginUI:2 withParams:params isLife:@"No"];
    }
    else{
//        [appDelegate sendRequestToFriends:params];
       
    }
    //self.displayRequestView.hidden=YES;
    [self cancelButtonClicked:sender];
}
-(void) cancelButtonClicked:(id)sender{
    
    //self.displayRequestView.hidden=YES;
    [UIView animateWithDuration:.3 animations:^{
        self.containerView.frame = CGRectMake(17, -300, 284, 278);
    }completion:^(BOOL finished){
        if (finished == YES) {
            self.displayRequestView.hidden = YES;
//            [self.gameStart setUserInteractionEnabled:YES];
        }
    }];
}
#pragma mark -
-(void) increaseUserLife:(NSDictionary *)dict{
    
    NSLog(@"Got new life");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int life = (int)[userDefaults integerForKey:@"life"];
    int newLife;
    if (life<5) {
        newLife = life + 1;
    }
    else{
        newLife = 5;
    }
    [userDefaults setInteger:newLife forKey:@"life"];
    [userDefaults  synchronize];
   
    [[[UIAlertView alloc] initWithTitle:@"Congratulation" message:[NSString stringWithFormat:@"You got new life"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];

}

-(void)loadInterstitial{
   
    if ([self.interstitial isReady]) {
        NSLog(@"inside");
        if ([GameStatus sharedState].isGamePlaying==NO) {
            [self.interstitial presentFromRootViewController:self];
        }
    }
}

- (GADInterstitial *)createAndLoadInterstitial {
    
    @try {
    
        GADInterstitial *interstitial = [[GADInterstitial alloc] init];
            //Testing
        interstitial.adUnitID = @"ca-app-pub-8909749042921180/1782851550";
        
            //Live
            //     interstitial.adUnitID = @"ca-app-pub-7881880964352996/3124406865";
        interstitial.delegate = self;
        
        GADRequest *request = [GADRequest request];
        
        [interstitial loadRequest:request];
        
            return interstitial;
        
        }
    @catch (NSException *exception) {
       NSLog(@"%@",[exception callStackSymbols]);
    }
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"add received");
    @try {
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception callStackSymbols]);
    }
   
}


- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    @try {
        self.interstitial = [self createAndLoadInterstitial];

    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception callStackSymbols]);
    }
    
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{

}

@end
