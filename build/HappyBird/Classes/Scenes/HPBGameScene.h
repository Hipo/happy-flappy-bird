//
//  HPBGameScene.h
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


typedef NS_ENUM(NSInteger, HPBGameSceneMode) {
    HPBGameSceneModeHappy,
    HPBGameSceneModeFlappy,
};


@protocol HPBGameSceneDelegate;

@interface HPBGameScene : SKScene

@property (nonatomic, weak) id <HPBGameSceneDelegate> delegate;

- (void)startGameWithMode:(HPBGameSceneMode)mode;
- (void)endGame;

@end


@protocol HPBGameSceneDelegate <NSObject>
@required
- (void)gameSceneDidStartGame:(HPBGameScene *)scene;
- (void)gameSceneDidEndGame:(HPBGameScene *)scene;
@end
