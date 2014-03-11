//
//  LoginViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "LoginViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *userNameField;
@property (nonatomic, strong) IBOutlet UITextField *pwdField;
@property (nonatomic, strong) IBOutlet UISwitch *autoLoginSwitch;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

- (IBAction)login:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_userNameField becomeFirstResponder];
    _userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 baas.io에 로그인 요청을 한다.
 로그인 버튼을 선택하거나 마지막 UITextField에서 Return 키를 눌렀을 때 호출된다.
 자동로그인에 체크되어 있으면 UserDefaults에 로그인 정보를 저장한다.
 */
- (void)login:(id)sender {
    [BaasioUser signInBackground:_userNameField.text password:_pwdField.text successBlock:^{
        if ([_autoLoginSwitch isOn]) {
            [_userDefaults setObject:_userNameField.text forKey:@"userName"];
            [_userDefaults setObject:_pwdField.text forKey:@"password"];
            [_userDefaults setBool:[_autoLoginSwitch isOn] forKey:@"autoLogin"];
            [_userDefaults synchronize];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(loginSuccess)]) {
                [self.delegate loginSuccess];
            }
        }];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"로그인 에러 : %@", error);
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그인 실패" description:error.description type:TWMessageBarMessageTypeError];
    }];
}

#pragma mark - UITextField Delegate
/**
 UITextField의 Delegate
 Return키를 누를때마다 호출된다. 호출한 TextFiled의 Tag를 확인 후 첫번째 TextField일 경우 다음 TextField를 호출
 마지막 TextField일 경우 키보드를 숨긴 후 로그인을 호출한다
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1000) {
        UIResponder *nextField = [textField.superview viewWithTag:1001];
        [nextField becomeFirstResponder];
    } else if (textField.tag == 1001) {
        [textField resignFirstResponder];
        [self login:nil];
    }
    
    return NO;
}

@end
