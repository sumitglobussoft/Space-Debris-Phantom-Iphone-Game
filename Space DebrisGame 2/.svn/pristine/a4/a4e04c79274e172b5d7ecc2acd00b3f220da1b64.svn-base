//
//  GameState.m
//  DartWheel
//
//  Created by Sumit Ghosh on 31/05/14.
//
//

#import "GameStatus.h"

static GameStatus *_sharedState = nil;

@implementation GameStatus


+(GameStatus*)sharedState {
    
    if (!_sharedState) {
        _sharedState=[[GameStatus alloc]init];
    }
    return _sharedState;
}

-(id)init{
    
    if (self=[super init]) {
        
    }
    return self;
}
@end
