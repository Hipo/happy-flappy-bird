//
//  HPBGameViewController.m
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import "HPBGameScene.h"
#import "HPBGameViewController.h"

#import "UIView+AutoLayout.h"


@interface HPBGameViewController () <HPBGameSceneDelegate>

@property (nonatomic, strong) HPBGameScene *gameScene;
@property (nonatomic, strong) SKView *gameView;
@property (nonatomic, strong) UIButton *flappyButton;
@property (nonatomic, strong) UIButton *happyButton;
@property (nonatomic, strong) UIButton *pauseButton;

- (void)didTapFlappyButton:(id)sender;
- (void)didTapHappyButton:(id)sender;
- (void)didTapPauseButton:(id)sender;

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
    
    CGSize startButtonSize = CGSizeMake(100.0, 44.0);

    _flappyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_flappyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_flappyButton setTitle:NSLocalizedString(@"FLAPPY", nil) forState:UIControlStateNormal];
    [_flappyButton.titleLabel setFont:[UIFont fontWithName:@"PressStart2P" size:14.0]];
    [_flappyButton addTarget:self
                    action:@selector(didTapFlappyButton:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_flappyButton];
    
    [_flappyButton autoSetDimensionsToSize:startButtonSize];
    [_flappyButton autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [_flappyButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];
    
    _happyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_happyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_happyButton setTitle:NSLocalizedString(@"HAPPY", nil) forState:UIControlStateNormal];
    [_happyButton.titleLabel setFont:[UIFont fontWithName:@"PressStart2P" size:14.0]];
    [_happyButton addTarget:self
                      action:@selector(didTapHappyButton:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_happyButton];
    
    [_happyButton autoSetDimensionsToSize:startButtonSize];
    [_happyButton autoCenterInSuperviewAlongAxis:ALAxisHorizontal];
    [_happyButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_pauseButton setAlpha:0.0];
    [_pauseButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_pauseButton setTitle:NSLocalizedString(@"X", nil) forState:UIControlStateNormal];
    [_pauseButton.titleLabel setFont:[UIFont fontWithName:@"PressStart2P" size:14.0]];
    [_pauseButton addTarget:self
                     action:@selector(didTapPauseButton:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_pauseButton];
    
    [_pauseButton autoSetDimensionsToSize:CGSizeMake(44.0, 44.0)];
    [_pauseButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:2.0];
    [_pauseButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:2.0];
}

#pragma mark - Control actions

- (void)didTapHappyButton:(id)sender {
    [_gameScene startGameWithMode:HPBGameSceneModeHappy];
}

- (void)didTapFlappyButton:(id)sender {
    [_gameScene startGameWithMode:HPBGameSceneModeFlappy];
}

- (void)didTapPauseButton:(id)sender {
    [_gameScene endGame];
}

#pragma mark - Game scene delegate

- (void)gameSceneDidStartGame:(HPBGameScene *)scene {
    [_happyButton setAlpha:0.0];
    [_flappyButton setAlpha:0.0];
    [_flappyButton setHidden:NO];
    [_happyButton setHidden:NO];
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_happyButton setAlpha:0.0];
                         [_flappyButton setAlpha:0.0];
                         [_pauseButton setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [_flappyButton setHidden:YES];
                         [_happyButton setHidden:YES];
                     }];
}

- (void)gameSceneDidEndGame:(HPBGameScene *)scene {
    [_happyButton setAlpha:0.0];
    [_flappyButton setAlpha:0.0];
    [_flappyButton setHidden:NO];
    [_happyButton setHidden:NO];

    [UIView animateWithDuration:0.33
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_happyButton setAlpha:1.0];
                         [_flappyButton setAlpha:1.0];
                         [_pauseButton setAlpha:0.0];
                     } completion:nil];
}

@end
