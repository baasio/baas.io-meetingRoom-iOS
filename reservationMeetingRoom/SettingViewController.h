//
//  SettingViewController.h
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 20..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingViewDelegate <NSObject>
- (void)logout;
@end

@interface SettingViewController : UIViewController

@property (nonatomic, weak) id <SettingViewDelegate> delegate;

@end
