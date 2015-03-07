//
//  NextLevelScene.h
//  Space Debris
//
//  Created by Sumit Ghosh on 29/07/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MyScene.h"
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>
@interface NextLevelScene : SKScene<AVAudioPlayerDelegate>
-(id)initWithSize:(CGSize)size playSound:(NSInteger)sound ;
@property(nonatomic,strong)NSString *strPostMessage;
@property(nonatomic,strong)  AVAudioPlayer * _musicPlayer;
@property(nonatomic,strong)NSString *str;
@property(nonatomic)int remainingCount;
@property(nonatomic)NSInteger soundORnot;
@property(nonatomic,strong)AppDelegate * appDelegate;
+(SKScene *)scene;
@end
