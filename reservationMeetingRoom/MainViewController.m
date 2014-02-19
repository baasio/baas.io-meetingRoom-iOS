//
//  MainViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 14..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "MainViewController.h"
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface MainViewController ()
@property (nonatomic, strong) UIScrollView *timeScrollView;
@end

@implementation MainViewController

@synthesize timeScrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setNavigationTitle {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.navigationItem setTitle:[dateFormatter stringFromDate:date]];
}

- (void)setTimeScrollView {
    timeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 40, self.view.frame.size.height)];
    [timeScrollView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:timeScrollView];
}

- (void)initialize {
    [self setNavigationTitle];
    [self setTimeScrollView];
}

@end
