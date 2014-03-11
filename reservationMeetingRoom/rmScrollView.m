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
#define DEFAULT_LINE_THICKNESS 0.5

@interface rmScrollView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *leftScrollView;
@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) NSArray *roomArray;
@property (nonatomic, strong) NSArray *reservationArray;

@end

@implementation rmScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _timeArray = @[ @"06시", @"07시", @"08시", @"09시", @"10시", @"11시", @"12시", @"13시", @"14시", @"15시", @"16시", @"17시", @"18시", @"19시", @"20시", @"21시", @"22시" ];
        
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
        _roomArray = objects;
        
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
    [query setWheres:[NSString stringWithFormat:@"organization = '%@' AND date = '%@'", [[BaasioUser currentUser] objectForKey:@"organization"], [dateFormatter stringFromDate:_currentDate]]];
    
    [query queryInBackground:^(NSArray *objects) {
        _reservationArray = objects;
        
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
            
            NSString *roomName = [dict objectForKey:@"roomName"];
            for (int i = 0; i < _roomArray.count; i++) {
                if ([roomName isEqualToString:[[_roomArray objectAtIndex:i] objectForKey:@"roomName"]]) {
                    roomIndex = i;
                    break;
                }
            }
            
            // 회의 타임테이블 뷰
            UIButton *meetingView = [[UIButton alloc] initWithFrame:CGRectMake(roomIndex * CELL_WIDTH, startTime * CELL_HEIGHT + 10, CELL_WIDTH, endTime * CELL_HEIGHT - startTime * CELL_HEIGHT)];
            CGFloat hue = ( arc4random() % 256 / 256.0 );
            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            
            [meetingView setBackgroundColor:color];
            
            // 회의 설명 라벨
            UILabel *meetingDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, meetingView.frame.size.width, meetingView.frame.size.height)];
            [meetingDescriptionLabel setTextColor:[UIColor whiteColor]];
            [meetingDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
            [meetingDescriptionLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [meetingDescriptionLabel setNumberOfLines:0];
            
            // 회의 설명
            NSString *meetingDescription = nil;
            if ([dict objectForKey:@"description"]) {
                meetingDescription = [NSString stringWithFormat:@"%@\n%@", [dict objectForKey:@"description"], [dict objectForKey:@"userName"]];
            } else {
                meetingDescription = [dict objectForKey:@"userName"];
            }
            
            [meetingDescriptionLabel setText:meetingDescription];
            [meetingView addSubview:meetingDescriptionLabel];
            
            // 회의 선택시 타겟 설정
            [meetingView addTarget:self action:@selector(reservationSelected:) forControlEvents:UIControlEventTouchUpInside];
            [meetingView setTag:[_reservationArray indexOfObject:dict]];
            
            [_mainScrollView addSubview:meetingView];
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"rmScrollView getReservationData fail : %@", error);
    }];
}

- (void)reservationSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *selectedData =[_reservationArray objectAtIndex:button.tag];
    
    if ([_delegate respondsToSelector:@selector(reservationDataSelected:)]) {
        [_delegate reservationDataSelected:selectedData];
    }
}

- (void)drawBackgroundLine {
    for (int i = 10; i < _mainScrollView.contentSize.height; i += CELL_HEIGHT) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, i, _mainScrollView.contentSize.width, DEFAULT_LINE_THICKNESS)];
        [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
        [_mainScrollView addSubview:lineView];
    }
    
    for (int i = 1; i < _roomArray.count; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i * CELL_WIDTH, 0, DEFAULT_LINE_THICKNESS, self.mainScrollView.contentSize.height)];
        [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
        [_mainScrollView addSubview:lineView];
    }
}

- (void)initMainScrollView {
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(44, _topScrollView.frame.size.height, self.frame.size.width - 44, self.frame.size.height - _topScrollView.frame.size.height)];
    [_mainScrollView setContentSize:CGSizeMake(CELL_WIDTH * _roomArray.count, _timeArray.count * CELL_HEIGHT * 2)];
    [_mainScrollView setDelegate:self];
    [self addSubview:_mainScrollView];
    
    [self drawBackgroundLine];
    [self getReservationData];
}

- (void)initLeftScrollView {
    _leftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topScrollView.frame.size.height, 44, self.frame.size.height - _topScrollView.frame.size.height)];
    [_leftScrollView setContentSize:CGSizeMake(44, _timeArray.count * CELL_HEIGHT * 2)];
    [_leftScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [_leftScrollView setDelegate:self];
    [self addSubview:_leftScrollView];
    
    for (int i = 0; i < _timeArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, i * CELL_HEIGHT * 2, 40, 20)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[_timeArray objectAtIndex:i]];
        [_leftScrollView addSubview:label];
    }
}

- (void)initTopScrollView {
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(44, 0, self.frame.size.width - 20, 20)];
    [_topScrollView setContentSize:CGSizeMake(CELL_WIDTH * _roomArray.count, 20)];
    [_topScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [self addSubview:_topScrollView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _topScrollView.contentSize.height - 0.5, _topScrollView.contentSize.width, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
    [_topScrollView addSubview:lineView];
    for (int i = 0; i < _roomArray.count; i++) {
        NSDictionary *dict = [_roomArray objectAtIndex:i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * CELL_WIDTH, 0, CELL_WIDTH, 20)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[dict objectForKey:@"roomName"]];
        [_topScrollView addSubview:label];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_leftScrollView]) {
        [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x, scrollView.contentOffset.y)];
    } else if ([scrollView isEqual:_mainScrollView]) {
        [_leftScrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y)];
        [_topScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    } else {
        [_mainScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, _mainScrollView.contentOffset.y)];
    }
}

@end
