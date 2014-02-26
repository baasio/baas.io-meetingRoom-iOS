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
    [Baasio setApplicationInfo:@"5d98fe39-65f0-11e2-bb6c-06fd000000c2" applicationName:@"8e22e1c0-9dec-11e3-ad13-06f4fe0000b5"];
    
    [BaasioPush registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    BaasioPush *push = [[BaasioPush alloc] init];
    NSArray *tag = @[@"test", @"male"];
    [push didRegisterForRemoteNotifications:deviceToken tags:tag successBlock:^{
        NSLog(@"푸시 등록 성공");
    } failureBlock:^(NSError *error) {
        NSLog(@"푸시 등록 실패 %@", error);
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"noti!!!! %@", userInfo);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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
