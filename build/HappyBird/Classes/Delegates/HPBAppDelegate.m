//
//  HPBAppDelegate.m
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import "HPBAppDelegate.h"
#import "HPBGameViewController.h"


@interface HPBAppDelegate ()

@end


@implementation HPBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    HPBGameViewController *controller = [[HPBGameViewController alloc] init];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [_window setRootViewController:controller];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
