//
//  LoginViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "LoginViewController.h"
#import <baas.io/Baas.h>

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *userNameField;
@property (nonatomic, strong) IBOutlet UITextField *pwdField;
@property (nonatomic, strong) IBOutlet UISwitch *autoLoginSwitch;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

- (IBAction)login:(id)sender;
@end

@implementation LoginViewController

@synthesize userNameField;
@synthesize pwdField;
@synthesize autoLoginSwitch;
@synthesize userDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userNameField becomeFirstResponder];
    userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)login:(id)sender {
    [BaasioUser signInBackground:userNameField.text password:pwdField.text successBlock:^{
        if ([autoLoginSwitch isOn]) {
            [userDefaults setObject:userNameField.text forKey:@"userName"];
            [userDefaults setObject:pwdField.text forKey:@"password"];
            [userDefaults setBool:autoLoginSwitch.state forKey:@"autoLogin"];
            [userDefaults synchronize];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(loginSuccess)]) {
                [self.delegate loginSuccess];
            }
        }];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"로그인 에러 : %@", error);
    }];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1000) {
        UIResponder *nextField = [textField.superview viewWithTag:1001];
        [nextField becomeFirstResponder];
    } else if (textField.tag == 1001) {
        [textField resignFirstResponder];
        [self login:nil];
    } else {
        NSLog(@"알수 없는 텍스트필드");
    }
    
    return NO;
}

@end
