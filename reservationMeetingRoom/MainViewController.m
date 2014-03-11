//
//  MainViewController.m
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 14..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "MainViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>
#import <RNBlurModalView/RNBlurModalView.h>

#import "rmScrollView.h"
#import "SettingViewController.h"
#import "AddMeetingViewController.h"

@interface MainViewController () <SettingViewDelegate, rmScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) rmScrollView *scrollView;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDictionary *selectedData;
@property (nonatomic, strong) RNBlurModalView *modalView;
@property (nonatomic, strong) NSString *addType;

- (IBAction)dayChange:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _addType = @"create";
    
    if (_scrollView != nil) {
        [_scrollView reloadView];
    } else {
        [self initialize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingPush"]) {
        SettingViewController *settingView = [segue destinationViewController];
        settingView.delegate = self;
    } else if ([segue.identifier isEqualToString:@"addMeetingPush"]) {
        AddMeetingViewController *addMeetingView = [segue destinationViewController];
        [addMeetingView setAddType:_addType];
        [addMeetingView setUpdateData:_selectedData];
    }
}

- (void)setNavigationTitle {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [_titleLabel setText:[dateFormatter stringFromDate:_currentDate]];
}

- (void)setScrollView {
    _scrollView = [[rmScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [_scrollView setDelegate:self];
    [_scrollView setCurrentDate:_currentDate];
    [self.view addSubview:_scrollView];
}

- (void)initialize {
    [self setNavigationTitle];
    [self setScrollView];
}

#pragma mark - rmScrollView Delegate
- (void)reservationDataSelected:(NSDictionary *)selectedData {
    _selectedData = selectedData;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 160)];
    UIColor *whiteColor = [UIColor colorWithRed:0.816 green:0.788 blue:0.788 alpha:1.000];
    
    view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8f];
    view.layer.borderColor = whiteColor.CGColor;
    view.layer.borderWidth = 2.f;
    view.layer.cornerRadius = 10.f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 110)];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    if ([selectedData objectForKey:@"description"]) {
        [label setText:[NSString stringWithFormat:@"%@ ~ %@\n%@\n%@\n%@", [selectedData objectForKey:@"startTime"], [selectedData objectForKey:@"endTime"], [selectedData objectForKey:@"roomName"], [selectedData objectForKey:@"description"], [selectedData objectForKey:@"userName"]]];
    } else {
        [label setText:[NSString stringWithFormat:@"%@ ~ %@\n%@\n%@", [selectedData objectForKey:@"startTime"], [selectedData objectForKey:@"endTime"], [selectedData objectForKey:@"roomName"], [selectedData objectForKey:@"userName"]]];
    }
    [view addSubview:label];
    
    if ([[selectedData objectForKey:@"userId"] isEqualToString:[[BaasioUser currentUser] objectForKey:@"username"]]) {
        UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [updateButton setTitle:@"수정" forState:UIControlStateNormal];
        [updateButton setFrame:CGRectMake(20, 110, 100, 30)];
        [updateButton addTarget:self action:@selector(updateReservationData) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:updateButton];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setTitle:@"삭제" forState:UIControlStateNormal];
        [deleteButton setFrame:CGRectMake(130, 110, 100, 30)];
        [deleteButton addTarget:self action:@selector(deleteReservationData) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:deleteButton];
    }
    
    _modalView = [[RNBlurModalView alloc] initWithViewController:self view:view];
    [_modalView setDismissButtonRight:YES];
    [_modalView show];
}

- (void)updateReservationData {
    NSLog(@"update %@", self.selectedData);
    _addType = @"update";
    [self performSegueWithIdentifier:@"addMeetingPush" sender:self];
    [_modalView hide];
}

- (void)deleteReservationData {
    BaasioEntity *entity = [BaasioEntity entitytWithName:@"meetings"];
    [entity setUuid:[self.selectedData objectForKey:@"uuid"]];
    
    [entity deleteInBackground:^{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 삭제 성공" description:@"예약이 삭제되었습니다" type:TWMessageBarMessageTypeSuccess];
        [_modalView hide];
        [_scrollView reloadView];
    } failureBlock:^(NSError *error) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 삭제 실패" description:@"예약을 삭제할 수 없습니다" type:TWMessageBarMessageTypeError];
    }];
}

#pragma mark - SettingView Delegate
- (void)logout {
    [self dismissViewControllerAnimated:YES completion:^{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"로그아웃" description:@"로그아웃 되었습니다" type:TWMessageBarMessageTypeInfo];
    }];
}

#pragma mark - IBAction
- (void)dayChange:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 31) {
        _currentDate = [NSDate dateWithTimeInterval:-(20*60*60) sinceDate:_currentDate];
    } else {
        _currentDate = [NSDate dateWithTimeInterval:(20*60*60) sinceDate:_currentDate];
    }
    [self setNavigationTitle];
    [_scrollView setCurrentDate:_currentDate];
    [_scrollView reloadView];
    
    NSLog(@"date change : %@", _currentDate);
}

@end
