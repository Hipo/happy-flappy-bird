//
//  HPBGameViewController.m
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import "HPBGameScene.h"
#import "HPBGameViewController.h"


@interface HPBGameViewController () <HPBGameSceneDelegate>

@property (nonatomic, strong) HPBGameScene *gameScene;
@property (nonatomic, strong) SKView *gameView;

@end


@implementation HPBGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _gameView = [[SKView alloc] initWithFrame:self.view.bounds];

    [_gameView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight)];
    
    [self.view addSubview:_gameView];
    
    _gameScene = [[HPBGameScene alloc] initWithSize:_gameView.bounds.size];
    
    [_gameScene setDelegate:self];
    
    [_gameView presentScene:_gameScene];
}

@end
