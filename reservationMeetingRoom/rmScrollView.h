//
//  rmScrollView.h
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 19..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol rmScrollViewDelegate <NSObject>

- (void)reservationDataSelected:(NSDictionary *)selectedData;

@end

@interface rmScrollView : UIView

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, weak) id <rmScrollViewDelegate> delegate;

- (void)reloadView;
- (void)initalize;

@end
