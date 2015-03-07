//
//  FriendsViewController.h
//  CaveRun
//
//  Created by GBS-ios on 8/18/14.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SBJson.h"
#import <FacebookSDK/FacebookSDK.h>


@interface FriendsViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) NSArray *friendListArray;
@property (nonatomic, retain) NSMutableArray *selectedFriendsArray;
@property (nonatomic, retain) NSMutableArray *selectedTagFriendsArray;
@property (nonatomic, retain) NSDictionary *paramDict;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSString *headerTitle;
@property(nonatomic,strong)UIImageView *logoImgView;
@property(nonatomic,strong)UILabel *textLabel;
@property (nonatomic, strong) UICollectionView *listTableView;
//@property(nonatomic,strong) UIImageView *checkButton ;
@property(nonatomic,strong) UIButton *checkButton ;
-(id)initWithHeaderTitle:(NSString *)headerTitle;

@end
