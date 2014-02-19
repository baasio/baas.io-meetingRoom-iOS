//
//  SignUpViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 13..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "SignUpViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface SignUpViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *idField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *organizationField;
@property (nonatomic, strong) IBOutlet UITextField *nameField;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

- (IBAction)signUp:(id)sender;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.idField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag >= 1000 && textField.tag <= 1003) {
        UIResponder *nextField = [textField.superview viewWithTag:textField.tag + 1];
        [nextField becomeFirstResponder];
    } else if (textField.tag == 1004) {
        [textField resignFirstResponder];
        [self signUp:nil];
    } else {
        NSLog(@"알수 없는 텍스트필드");
    }
    
    return NO;
}

#pragma mark - IBAction
- (void)signUp:(id)sender {
    BaasioUser *user = [BaasioUser user];
    [user setObject:self.idField.text forKey:@"username"];
    [user setObject:self.passwordField.text forKey:@"password"];
    [user setObject:self.nameField.text forKey:@"name"];
    [user setObject:self.emailField.text forKey:@"email"];
    [user setObject:self.organizationField.text forKey:@"organization"];
    
    [user signUpInBackground:^{
        [self.userDefaults setObject:self.idField.text forKey:@"userName"];
        [self.userDefaults setObject:self.passwordField.text forKey:@"password"];
        [self.userDefaults setBool:YES forKey:@"autoLogin"];
        [self.userDefaults synchronize];
        
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(signUpSuccess)]) {
                [self.delegate signUpSuccess];
            }
        }];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"회원가입이 실패했습니다 : %@", error);
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"회원가입에 실패했습니다" description:error.description type:TWMessageBarMessageTypeError];
    }];
}

@end
