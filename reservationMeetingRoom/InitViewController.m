//
//  ViewController.m
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 12..
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

- (void)viewDidLoad {
    [super viewDidLoad];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 자동 로그인 체크
    [self checkSavedLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 userDefaults 에 userName과 autoLogin을 이용하여 자동로그인 허용인지 확인 후
 있을 경우 로그인 시도
 성공시 MainViewController를 호출
 실패시 메세지 출력 후 대기
 */
- (void)checkSavedLogin {
    NSString *savedUserName = [_userDefaults objectForKey:@"userName"];
    BOOL autoLogin = [_userDefaults boolForKey:@"autoLogin"];
    if (savedUserName != nil && autoLogin) {
        NSString *savedUserPwd = [_userDefaults objectForKey:@"password"];
        [BaasioUser signInBackground:savedUserName password:savedUserPwd successBlock:^{
            NSLog(@"autoLogin success id = %@, pwd = %@", savedUserName, savedUserPwd);
            [self loginSuccess];
        } failureBlock:^(NSError *error) {
            NSLog(@"autoLogin failure");
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그인 실패" description:error.description type:TWMessageBarMessageTypeError];
        }];
    }
}

/**
 segue를 호출 할 때 캐치해서 Delegate 설정
 */
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
/**
 로그인이 성공했을때 LoginViewController에서 Delegate 호출
 MainViewController를 호출한다
 */
- (void)loginSuccess {
    BaasioUser *user = [BaasioUser currentUser];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그인 성공" description:[NSString stringWithFormat:@"%@님 환영합니다", user.username] type:TWMessageBarMessageTypeSuccess];
    [UIView animateWithDuration:0.1 animations:nil completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"mainModal" sender:nil];
    }];
}

#pragma mark - SignUp View Delegate
/**
 회원가입에 성공했을 때 SignUpViewController에서 Delegate호출
 회원가입 성공 시 로그인 정보를 저장하므로 자동로그인인지 체크 후 자동로그인이면 로그인 루틴을 탄다
 */
- (void)signUpSuccess {
    [self checkSavedLogin];
    BaasioUser *user = [BaasioUser currentUser];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"회원가입 성공" description:[NSString stringWithFormat:@"%@님 환영합니다", user.username] type:TWMessageBarMessageTypeSuccess];
    NSLog(@"회원가입 성공, 현재유저 : %@", user);
}

@end
