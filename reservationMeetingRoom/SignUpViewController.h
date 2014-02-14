//
//  SignUpViewController.h
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 13..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpViewDelegate <NSObject>
- (void)signUpSuccess;
@end

@interface SignUpViewController : UIViewController
@property (nonatomic, weak) id <SignUpViewDelegate> delegate;
@end
