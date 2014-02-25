//
//  ViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "InitViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface InitViewController () <LoginViewDelegate, SignUpViewDelegate>
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation InitViewController

@synthesize userDefaults;

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self checkSavedLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)checkSavedLogin {
    NSString *savedUserName = [userDefaults objectForKey:@"userName"];
    BOOL autoLogin = [userDefaults boolForKey:@"autoLogin"];
    if (savedUserName != nil && autoLogin) {
        NSString *savedUserPwd = [userDefaults objectForKey:@"password"];
        [BaasioUser signInBackground:savedUserName password:savedUserPwd successBlock:^{
            NSLog(@"autoLogin success id = %@, pwd = %@", savedUserName, savedUserPwd);
            [self loginSuccess];
        } failureBlock:^(NSError *error) {
            NSLog(@"autoLogin failure");
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그인 실패" description:error.description type:TWMessageBarMessageTypeError];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginModal"]) {
        LoginViewController *loginView = segue.destinationViewController;
        loginView.delegate = self;
    } else if ([segue.identifier isEqualToString:@"signUpModal"]) {
        SignUpViewController *signUpView = segue.destinationViewController;
        signUpView.delegate = self;
    }
}

#pragma mark - LoginView Delegate
- (void)loginSuccess {
    BaasioUser *user = [BaasioUser currentUser];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그인 성공" description:[NSString stringWithFormat:@"%@님 환영합니다", user.username] type:TWMessageBarMessageTypeSuccess];
    [UIView animateWithDuration:0.1 animations:nil completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"mainModal" sender:nil];
    }];
}

#pragma mark - SignUp View Delegate
- (void)signUpSuccess {
    [self checkSavedLogin];
    BaasioUser *user = [BaasioUser currentUser];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"회원가입 성공" description:[NSString stringWithFormat:@"%@님 환영합니다", user.username] type:TWMessageBarMessageTypeSuccess];
    NSLog(@"회원가입 성공, 현재유저 : %@", user);
}

@end
