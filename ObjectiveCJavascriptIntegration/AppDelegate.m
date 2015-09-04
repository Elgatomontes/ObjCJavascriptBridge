//
//  AppDelegate.m
//  ObjectiveCJavascriptIntegration
//
//  Created by Gaston Montes on 2/9/15.
//  Copyright (c) 2015 Gaston Montes. All rights reserved.
//

#import "HelloWorldViewController.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create first view controller.
    HelloWorldViewController *helloWorld = [[HelloWorldViewController alloc] init];
    
    // Initialize windows.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = helloWorld;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
