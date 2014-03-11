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
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [_idField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate
/**
 UITextField의 Delegate
 Return키를 누를때마다 호출된다. 호출한 TextFiled의 Tag를 확인 후 첫번째 TextField일 경우 다음 TextField를 호출
 마지막 TextField일 경우 키보드를 숨긴 후 회원가입을 호출한다
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag >= 1000 && textField.tag <= 1003) {
        UIResponder *nextField = [textField.superview viewWithTag:textField.tag + 1];
        [nextField becomeFirstResponder];
    } else if (textField.tag == 1004) {
        [textField resignFirstResponder];
        [self signUp:nil];
    }
    
    return NO;
}

#pragma mark - IBAction
/**
 baas.io에 회원가입 호출
 */
- (void)signUp:(id)sender {
    BaasioUser *user = [BaasioUser user];
    [user setObject:_idField.text forKey:@"username"];
    [user setObject:_passwordField.text forKey:@"password"];
    [user setObject:_nameField.text forKey:@"name"];
    [user setObject:_emailField.text forKey:@"email"];
    [user setObject:_organizationField.text forKey:@"organization"];
    
    [user signUpInBackground:^{
        [_userDefaults setObject:_idField.text forKey:@"userName"];
        [_userDefaults setObject:_passwordField.text forKey:@"password"];
        [_userDefaults setBool:YES forKey:@"autoLogin"];
        [_userDefaults synchronize];
        
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
