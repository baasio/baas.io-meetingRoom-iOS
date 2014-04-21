//
//  SettingViewController.m
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 20..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "SettingViewController.h"
#import <baas.io/Baas.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SettingViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UISwitch *pushSwitch;
@property (nonatomic, weak) IBOutlet UIButton *logoutButton;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BaasioUser *currentUser = [BaasioUser currentUser];
    [_nameLabel setText:currentUser.username];
    
    [[_logoutButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self logout];
    }];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _pushSwitch.on = [userDefaults boolForKey:@"pushonoff"];
    
    [[_pushSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        [userDefaults setBool:_pushSwitch.isOn forKey:@"pushonoff"];
        BaasioPush *push = [[BaasioPush alloc] init];
        if (_pushSwitch.isOn) {
            [push pushOnInBackground:^(void) {
                NSLog(@"push on success.");
            }
                        failureBlock:^(NSError *error) {
                            NSLog(@"push on fail : %@", error.localizedDescription);
                        }];
        } else {
            [push pushOffInBackground:^(void) {
                NSLog(@"push off success.");
            }
                         failureBlock:^(NSError *error) {
                             NSLog(@"push off fail : %@", error.localizedDescription);
                         }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logout {
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
