//
//  GameState.h
//  DartWheel
//
//  Created by Sumit Ghosh on 31/05/14.
//
//

#import <Foundation/Foundation.h>
#import "LifeOver.h"

@interface GameStatus : NSObject

@property (nonatomic, assign) NSInteger levelNumber;
//@property (nonatomic, assign) int latestScore;
@property (nonatomic, assign) NSInteger remLife;
@property (nonatomic, assign) NSInteger remTime;
@property (nonatomic, assign) NSInteger remScore;
@property (nonatomic, assign) BOOL checkLevelClear;
@property (nonatomic, retain) NSArray *scoreArray;
@property (nonatomic, assign) BOOL checkLife;
@property (nonatomic,assign) BOOL isGamePlaying ;
//@property(nonatomic)LifeOver *lifeOver;



+(GameStatus*)sharedState;
@end
