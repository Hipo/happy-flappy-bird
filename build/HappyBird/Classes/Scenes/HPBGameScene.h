//
//  HPBGameScene.h
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@protocol HPBGameSceneDelegate;

@interface HPBGameScene : SKScene

@property (nonatomic, weak) id <HPBGameSceneDelegate> delegate;

@end


@protocol HPBGameSceneDelegate <NSObject>
@required

@end
