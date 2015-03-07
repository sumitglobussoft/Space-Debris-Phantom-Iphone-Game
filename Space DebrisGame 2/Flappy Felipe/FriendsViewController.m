//
//  FriendsViewController.m
//  CaveRun
//
//  Created by GBS-ios on 8/18/14.
//
//

#import "FriendsViewController.h"
#import "UIImageView+WebCache.h"
#import "ImageViewCustomCell.h"


@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithHeaderTitle:(NSString *)headerTitle{
    
    self = [super init];
    if (self) {
//        self.headerTitle = headerTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.view.frame.size.height>500) {
         self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg1.png"]];
    }else{
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blankbg.png"]];
    
    }
   
    self.frame = [UIScreen mainScreen].bounds;
    [self createUI];
    
    NSArray *frndsListArray = [[NSUserDefaults standardUserDefaults] objectForKey:FacebookAllFriends];
    NSLog(@"frnds = %@",frndsListArray);
    self.friendListArray = [NSArray arrayWithArray:frndsListArray];
    self.selectedFriendsArray = [[NSMutableArray alloc] init];
    self.selectedTagFriendsArray = [[NSMutableArray alloc] init];
    [self.selectedTagFriendsArray addObjectsFromArray:self.friendListArray];
    NSMutableArray *tagArray=[[NSMutableArray alloc] init];
    
    if (self.friendListArray.count<50) {
        for (int i=0 ; i<self.friendListArray.count; i++) {

        [self.selectedFriendsArray addObject:[NSNumber numberWithInteger:i]];
//       [self.selectedTagFriendsArray exchangeObjectAtIndex:randomNumber withObjectAtIndex:i];
        }
    }else{
        for (int i=0 ; i<self.friendListArray.count; i++) {
            
            NSInteger randomNumber = arc4random() % self.friendListArray.count;
            
          if (![tagArray containsObject:[NSNumber numberWithInteger:randomNumber]]) {
//                 [tagArray addObject:[NSNumber numberWithInteger:randomNumber]];
          [self.selectedTagFriendsArray exchangeObjectAtIndex:randomNumber withObjectAtIndex:i];
                 [tagArray addObject:[NSNumber numberWithInteger:i]];
           }
            
            if (tagArray.count==50) {
                break;
            }
           
        }
        [self.selectedFriendsArray addObjectsFromArray:tagArray];

    }
       [self createTableView];

}

-(void)viewWillAppear:(BOOL)animated{
    
//    NSArray *frndsListArray = [[NSUserDefaults standardUserDefaults] objectForKey:FacebookAllFriends];
//    NSLog(@"frnds = %@",frndsListArray);
   
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) createUI{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, self.frame.size.width-10, 370)] ;
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.headerView.bounds;
    self.headerView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ask_extra_lives.png"]];

    
    [self.view addSubview:self.headerView];
    
    //Add Cancel Button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(230,-5,120, 60);
    [cancelButton setImage:[UIImage imageNamed:@"close_big_btn.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:cancelButton];
    
    //Add Send Button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(self.frame.size.width-94, 320, 50, 25);
    [sendButton setImage:[UIImage imageNamed:@"send@2x.png"]  forState:UIControlStateNormal];
   
    [sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:sendButton];
    
    //===========
    //Add Title Label
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 390, self.view.frame.size.width-20, 75)] ;
    noteLabel.textColor = [UIColor blueColor];
    noteLabel.font = [UIFont boldSystemFontOfSize:10];
    noteLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"note.png"]];
    noteLabel.lineBreakMode=NSLineBreakByCharWrapping;
    noteLabel.text=@"Note: You will get 1 life for every five friends.\nSo tag as many as you want.";
    noteLabel.textAlignment = NSTextAlignmentCenter;
   noteLabel.numberOfLines = 0;
    [self.view addSubview:noteLabel];
//    [noteLabel sizeToFit];
}

-(void) createTableView{
//    self.logoImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, self.headerView.frame.size.height, 80, 80)];
//    self.logoImgView.image=[UIImage imageNamed:@"icon-29pt.png"];
//    [self.view addSubview:self.logoImgView];
//    
    self.textLabel=[[UILabel alloc]initWithFrame: CGRectMake(35, 310, 240, 25)];
    self.textLabel.text=[NSString stringWithFormat:@"%lu friends selected",(unsigned long)self.selectedFriendsArray.count];
    self.textLabel.textColor=[UIColor blueColor];
    self.textLabel.font=[UIFont fontWithName:@"" size:2];
    self.textLabel.textAlignment=NSTextAlignmentNatural;
    self.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    self.textLabel.numberOfLines=0;
    self.textLabel.backgroundColor=[UIColor clearColor];
    [self.headerView addSubview:self.textLabel];
     [self.textLabel sizeToFit];
    

     UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
     [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setItemSize:CGSizeMake(125, 40)];
    
    self.listTableView = [[UICollectionView alloc] initWithFrame:CGRectMake(25,85, self.frame.size.width-60, 200) collectionViewLayout:layout];
       [self.listTableView registerClass:[ImageViewCustomCell class] forCellWithReuseIdentifier:@"cell"];
    [self.listTableView setBackgroundColor:[UIColor clearColor]];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self.headerView addSubview:self.listTableView];
}

#pragma mark-
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
//    return self.friendListArray.count;
     return self.selectedTagFriendsArray.count;
    }
// 2


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * identifier=@"cell";

//    NSDictionary *dict = [self.friendListArray objectAtIndex:indexPath.row];
      NSDictionary *dict = [self.selectedTagFriendsArray objectAtIndex:indexPath.row];
    NSString *imageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pic_small"]];
    
    ImageViewCustomCell * cell=(ImageViewCustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"icon-58.png"]];
    NSLog(@"%@ name = ",[dict objectForKey:@"name"]);
    
    self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkButton setImage:[UIImage imageNamed:@"plus_icon.png"] forState:UIControlStateNormal ];
   [self.checkButton setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateSelected ];
    NSNumber *indexPasth=[NSNumber numberWithInteger:indexPath.row];
    if (![self.selectedFriendsArray containsObject:indexPasth]) {
    [self.checkButton setImage:[UIImage imageNamed:@"plus_icon.png"] forState:UIControlStateNormal ];

    }else{
      [self.checkButton setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateNormal ];
    [self.checkButton setImage:[UIImage imageNamed:@"plus_icon.png"] forState:UIControlStateSelected ];
//      self.checkButton.selected = YES;

    
    }
    self.checkButton.frame = CGRectMake(100.0, 10.0, 20.0, 20.0);
    self.checkButton.tag=indexPath.row;
    self.checkButton.userInteractionEnabled = YES;
    [self.checkButton addTarget:self action:@selector(buttonTouch:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:self.checkButton];

    NSString* nameStr = [dict objectForKey:@"name"];
    NSArray* firstLastStrings = [nameStr componentsSeparatedByString:@" "];
    NSString* firstName = [firstLastStrings objectAtIndex:0];
    NSString* lastName = [firstLastStrings objectAtIndex:1];
//    char lastInitialChar = [lastName characterAtIndex:0];
//    NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar]
       cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",firstName,lastName];
    return cell;
}

- (void)buttonTouch:(UIButton *)aButton withEvent:(UIEvent *)event
{
    aButton.selected = ! aButton.selected;

    NSInteger bu=aButton.tag;
       NSNumber *indexpath=[NSNumber numberWithInteger:bu];
    if (![self.selectedFriendsArray containsObject:indexpath]) {
        [self.selectedFriendsArray addObject:indexpath];
        if (self.selectedFriendsArray.count==1) {
            self.textLabel.text=[NSString stringWithFormat:@"%lu friend selected",(unsigned long)self.selectedFriendsArray.count];
        }else{
            self.textLabel.text=[NSString stringWithFormat:@"%lu friends selected",(unsigned long)self.selectedFriendsArray.count];
        }
    }else{
    
     [self.selectedFriendsArray removeObject:indexpath];
        
        if (self.selectedFriendsArray.count==1) {
            self.textLabel.text=[NSString stringWithFormat:@"%lu friend selected",(unsigned long)self.selectedFriendsArray.count];
        }else if(self.selectedFriendsArray.count>1){
            self.textLabel.text=[NSString stringWithFormat:@"%lu friends selected",(unsigned long)self.selectedFriendsArray.count];
        }else{
        self.textLabel.text=@"No friend selected";
        }

    }

}



//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//   
//    NSLog(@"Indexpath.row %lu",(long)indexPath.row);
//
//if (![self.selectedFriendsArray containsObject:indexPath]) {
//       [self.selectedFriendsArray addObject:indexPath];
//    }
//
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    if ([self.selectedFriendsArray containsObject:indexPath]) {
//        [self.selectedFriendsArray removeObject:indexPath];
//    }
//
//
//}

//testtttt

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    return YES;  // YES for the Cut, copy, paste actions
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    NSLog(@"performAction");
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [self.friendListArray objectAtIndex:indexPath.row];
    NSString *imageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pic_small"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"icon-58.png"]];
    // Configure the cell...
    @try {
        if ([self.selectedFriendsArray containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception = %@",[exception name]);
    }
    @finally {
        NSLog(@"Finally");
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:.5 animations:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell.accessoryType==UITableViewCellAccessoryCheckmark) {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([self.selectedFriendsArray containsObject:indexPath]) {
            [self.selectedFriendsArray removeObject:indexPath];
        }
        
    }
    else{
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriendsArray addObject:indexPath];
    }
}

*/
#pragma mark -
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- 
#pragma mark Button Action

-(void) cancelButtonClicked:(id)sender{
    [UIView animateWithDuration:1 animations:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

-(void) sendButtonClicked:(id)sender{
    //NSLog(@"Self. selected friends = %@", self.selectedFriendsArray);
    

    if (self.selectedFriendsArray.count<5) {
        [[[UIAlertView alloc] initWithTitle:@"Select atleast five friend to get life" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    
    NSMutableString *selectedFrndsString = [[NSMutableString alloc] init];
    for (int i =0; i < self.selectedFriendsArray.count; i++) {
        NSNumber *indexPath = [self.selectedFriendsArray objectAtIndex:i];
//        NSDictionary *dict = [self.friendListArray objectAtIndex:[indexPath integerValue]];
         NSDictionary *dict = [self.selectedTagFriendsArray objectAtIndex:[indexPath integerValue]];
        NSString *toString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"uid"]];
        
        if (i== self.selectedFriendsArray.count-1) {
             [selectedFrndsString appendString:toString];
        }
        else{
            [selectedFrndsString appendString:[NSString stringWithFormat:@"%@,",toString]];
        }
    }
    NSLog(@"Selected Friends String = %@",selectedFrndsString);
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.delegate = self;
//    SBJsonWriter *jsonWriter = [SBJsonWriter new];
//    NSDictionary *challenge =  [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"Life Request"], @"message", nil];
//    NSString *lifeReq = [jsonWriter stringWithObject:challenge];
    
    appDelegate.openGraphDict = nil;
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
  
    
//      NSDictionary *storyDict = [NSDictionary dictionaryWithObjectsAndKeys:selectedFrndsString, @"tags",@"count",self.selectedFriendsArray.count, nil];
//    appDelegate.openGraphDict = storyDict;

    
    if (FBSession.activeSession.isOpen) {
        appDelegate.friendsList=selectedFrndsString;
        appDelegate.friendsCount=self.selectedFriendsArray.count;
        [appDelegate sendRequestToFriends:selectedFrndsString];

    }
    else{
        appDelegate.friendsList=selectedFrndsString;
        appDelegate.friendsCount=self.selectedFriendsArray.count;
        [appDelegate openSessionWithLoginUI:2 withParams:nil isLife:@"No"];
    }
    
    [UIView animateWithDuration:1 animations:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

}

-(void)hideFacebookFriendsList{
    [self cancelButtonClicked:nil];
}
@end
