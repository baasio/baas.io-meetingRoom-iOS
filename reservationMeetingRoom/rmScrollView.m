//
//  rmScrollView.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 19..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "rmScrollView.h"
#import <baas.io/Baas.h>

#define CELL_HEIGHT 44
#define CELL_WIDTH 100

@interface rmScrollView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *leftScrollView;
@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) NSArray *roomArray;
@property (nonatomic, strong) NSArray *reservationArray;

@end

@implementation rmScrollView

@synthesize currentDate;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.timeArray = [[NSArray alloc] initWithObjects:@"06시", @"07시", @"08시", @"09시", @"10시", @"11시", @"12시", @"13시", @"14시", @"15시", @"16시", @"17시", @"18시", @"19시", @"20시", @"21시", @"22시", nil];
        
        [self initalize];
    }
    return self;
}

- (void)reloadView {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self initalize];
}

- (void)initalize {
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"meeting_rooms"];
    [query setProjectionIn:@"*"];
    [query setOrderBy:@"roomName" order:BaasioQuerySortOrderASC];
    [query setWheres:[NSString stringWithFormat:@"organization = '%@'", [[BaasioUser currentUser] objectForKey:@"organization"]]];
    
    [query queryInBackground:^(NSArray *objects) {
        self.roomArray = objects;
        
        [self initTopScrollView];
        [self initLeftScrollView];
        [self initMainScrollView];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"load rooms fail %@", error);
    }];
}

- (void)getReservationData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyMMdd"];
    
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"meetings"];
    [query setProjectionIn:@"*"];
    [query setOrderBy:@"roomName" order:BaasioQuerySortOrderASC];
    [query setWheres:[NSString stringWithFormat:@"organization = '%@' AND date = '%@'", [[BaasioUser currentUser] objectForKey:@"organization"], [dateFormatter stringFromDate:currentDate]]];
    
    [query queryInBackground:^(NSArray *objects) {
        self.reservationArray = objects;
        
        for (NSDictionary *dict in objects) {
            NSInteger startTime = ([[dict objectForKey:@"startTime"] integerValue] - [[[dict objectForKey:@"startTime"] substringToIndex:2] integerValue] * 70) / 15 - 12;
            if ([[[dict objectForKey:@"startTime"] substringFromIndex:2] isEqualToString:@"30"]) {
                startTime = startTime - 1;
            }
            NSInteger endTime = ([[dict objectForKey:@"endTime"] integerValue] - [[[dict objectForKey:@"endTime"] substringToIndex:2] integerValue] * 70) / 15 - 12;
            if ([[[dict objectForKey:@"endTime"] substringFromIndex:2] isEqualToString:@"30"]) {
                endTime = endTime - 1;
            }
            
            NSInteger roomIndex = 0;
            
            for (int i = 0; i < self.roomArray.count; i++) {
                if ([[[self.roomArray objectAtIndex:i] objectForKey:@"roomName"] isEqualToString:[dict objectForKey:@"roomName"]]) {
                    roomIndex = i;
                    break;
                }
            }
            
            UIButton *meetingView = [[UIButton alloc] initWithFrame:CGRectMake(roomIndex * CELL_WIDTH, startTime * CELL_HEIGHT + 10, CELL_WIDTH, endTime * CELL_HEIGHT - startTime * CELL_HEIGHT)];
            CGFloat hue = ( arc4random() % 256 / 256.0 );
            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            
            [meetingView setBackgroundColor:color];
            
            UILabel *meetingDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, meetingView.frame.size.width, meetingView.frame.size.height)];
            [meetingDescriptionLabel setTextColor:[UIColor whiteColor]];
            [meetingDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
            [meetingDescriptionLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [meetingDescriptionLabel setText:[dict objectForKey:@"userName"]];
            [meetingView addSubview:meetingDescriptionLabel];
            
            [meetingView addTarget:self action:@selector(reservationSelected:) forControlEvents:UIControlEventTouchUpInside];
            [meetingView setTag:[self.reservationArray indexOfObject:dict]];
            
            [self.mainScrollView addSubview:meetingView];
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"rmScrollView getReservationData fail : %@", error);
    }];
}

- (void)reservationSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *selectedData =[self.reservationArray objectAtIndex:button.tag];
    
    if ([self.delegate respondsToSelector:@selector(reservationDataSelected:)]) {
        [self.delegate reservationDataSelected:selectedData];
    }
    
    NSLog(@"click %@", selectedData);
}

- (void)drawBackgroundLine {
    for (int i = 10; i < self.mainScrollView.contentSize.height; i += CELL_HEIGHT) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, i, self.mainScrollView.contentSize.width, 0.5)];
        [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
        [self.mainScrollView addSubview:lineView];
    }
    
    for (int i = 1; i < self.roomArray.count; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i * CELL_WIDTH, 0, 0.5, self.mainScrollView.contentSize.height)];
        [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
        [self.mainScrollView addSubview:lineView];
    }
}

- (void)initMainScrollView {
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(44, self.topScrollView.frame.size.height, self.frame.size.width - 44, self.frame.size.height - self.topScrollView.frame.size.height)];
    [self.mainScrollView setContentSize:CGSizeMake(CELL_WIDTH * self.roomArray.count, self.timeArray.count * CELL_HEIGHT * 2)];
    [self.mainScrollView setDelegate:self];
    [self addSubview:self.mainScrollView];
    
    [self drawBackgroundLine];
    [self getReservationData];
}

- (void)initLeftScrollView {
    self.leftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topScrollView.frame.size.height, 44, self.frame.size.height - self.topScrollView.frame.size.height)];
    [self.leftScrollView setContentSize:CGSizeMake(44, self.timeArray.count * CELL_HEIGHT * 2)];
    [self.leftScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [self.leftScrollView setDelegate:self];
    [self addSubview:self.leftScrollView];
    
    for (int i = 0; i < self.timeArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, i * CELL_HEIGHT * 2, 40, 20)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[self.timeArray objectAtIndex:i]];
        [self.leftScrollView addSubview:label];
    }
}

- (void)initTopScrollView {
    self.topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(44, 0, self.frame.size.width - 20, 20)];
    [self.topScrollView setContentSize:CGSizeMake(CELL_WIDTH * self.roomArray.count, 20)];
    [self.topScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [self addSubview:self.topScrollView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topScrollView.contentSize.height - 0.5, self.topScrollView.contentSize.width, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
    [self.topScrollView addSubview:lineView];
    for (int i = 0; i < self.roomArray.count; i++) {
        NSDictionary *dict = [self.roomArray objectAtIndex:i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * CELL_WIDTH, 0, CELL_WIDTH, 20)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[dict objectForKey:@"roomName"]];
        [self.topScrollView addSubview:label];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.leftScrollView]) {
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, scrollView.contentOffset.y)];
    } else if ([scrollView isEqual:self.mainScrollView]) {
        [self.leftScrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
        [self.topScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    } else {
        [self.mainScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, self.mainScrollView.contentOffset.y)];
    }
}

@end
