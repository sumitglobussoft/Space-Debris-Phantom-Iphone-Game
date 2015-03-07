//
//  LevelSelectionViewController.m
//  Space Debris
//
//  Created by Globussoft 1 on 6/19/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "LevelSelectionViewController.h"
#import "LevelSelectionScene.h"
#import "MyScene.h"
#import <SpriteKit/SpriteKit.h>

@interface LevelSelectionViewController ()

@end

@implementation LevelSelectionViewController
@synthesize skView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"hi");
    
//    skView = (SKView *)self.view;
//  skView.showsFPS = NO;
//   skView.showsNodeCount = NO;
//    
//        // Create and configure the scene.
//    SKScene * scene = [[LevelSelectionScene alloc] initWithSize:skView.bounds.size];
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//    
//        // Present the scene.
//    [skView presentScene:scene];
//    
////    skView = (SKView *)self.view;
////    skView.showsFPS = YES;
////    skView.showsNodeCount = YES;
//    self.view.backgroundColor=[UIColor blueColor];
//    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 120, 270, 250)];
//    scrollV.contentSize=CGSizeMake(270, 500);
//    scrollV.scrollEnabled=YES;
//    scrollV.backgroundColor=[UIColor redColor];
//    scrollV.showsHorizontalScrollIndicator=YES;
//    [self.view addSubview:scrollV];
//    
//    for (int i=0; i<4; i++) {
//        
//        for (int j=0; j<10; j++) {
//       UIButton * btnLevels = [UIButton buttonWithType:UIButtonTypeSystem];
//            
//            btnLevels.frame=CGRectMake(15+65*i, 50*j, 48, 48);
//            unsigned buttonNumber = j*4+i+1;
//            btnLevels.tag=buttonNumber;
//                //                NSLog(@"button level tag %d",btnLevels.tag);
////            btnLevels.titleLabel.font=[UIFont
////                                       fontWithName:@"NKOTB Fever" size:20];
//            [btnLevels setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [btnLevels addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
////            [btnLevels setBackgroundImage:[UIImage imageNamed:@"Button.png"] forState:UIControlStateNormal];
//            btnLevels.backgroundColor=[UIColor whiteColor];
//            [scrollV addSubview:btnLevels];
//        }
//    }
        // Do any additional setup after loading the view.
}
-(void)btnAction:(UIButton *)button{
    
   skView = (SKView *)self.view;
//    skView.showsFPS = NO;
//    skView.showsNodeCount = NO;
    
        // Create and configure the scene.
    SKScene * scene = [[LevelSelectionScene alloc] initWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
        // Present the scene.
    [skView presentScene:scene];

    
// LevelSelectionScene * scene = [LevelSelectionScene sceneWithSize:skView.bounds.size];
//    
//    scene.scaleMode = SKSceneScaleModeAspectFill;
    
        // Set the delegate
//    [scene setDelegate:self];
    
        // Present the scene
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
