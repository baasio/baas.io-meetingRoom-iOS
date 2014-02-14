//
//  AppDelegate.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "AppDelegate.h"
#import <baas.io/Baas.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Baasio setApplicationInfo:@"5d98fe39-65f0-11e2-bb6c-06fd000000c2" applicationName:@"765b3806-93b5-11e3-bb03-06a6fa0000b9"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
