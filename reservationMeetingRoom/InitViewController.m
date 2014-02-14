//
//  ViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "InitViewController.h"
#import <baas.io/Baas.h>

@interface InitViewController ()
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

- (void)callLoginView {
    [self performSegueWithIdentifier:@"loginModal" sender:nil];
}

- (void)loginSuccess {
    NSLog(@"로그인 성공");
    [UIView animateWithDuration:0.1 animations:nil completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"mainModal" sender:nil];
    }];
}

- (void)signUpSuccess {
    [self checkSavedLogin];
    NSLog(@"회원가입 성공, 현재유저 : %@", [BaasioUser currentUser]);
}

@end
