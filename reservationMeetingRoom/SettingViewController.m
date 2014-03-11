//
//  SettingViewController.m
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 20..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "SettingViewController.h"
#import <baas.io/Baas.h>

@interface SettingViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UISwitch *pushSwitch;

- (IBAction)logout:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BaasioUser *currentUser = [BaasioUser currentUser];
    [_nameLabel setText:currentUser.username];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logout:(id)sender {
    NSLog(@"[SettingView] Log out called");
    
    [BaasioUser signOut];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"userName"];
    [userDefaults setObject:nil forKey:@"password"];
    [userDefaults setBool:NO forKey:@"autoLogin"];
    [userDefaults synchronize];
    
    if ([self.delegate respondsToSelector:@selector(logout)]) {
        [self.delegate logout];
    }
}

@end
