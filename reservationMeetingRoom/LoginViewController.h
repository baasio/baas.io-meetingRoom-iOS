//
//  LoginViewController.h
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 12..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewDelegate <NSObject>
- (void)loginSuccess;
@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id <LoginViewDelegate> delegate;

@end
