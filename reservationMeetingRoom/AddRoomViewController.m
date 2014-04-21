//
//  AddRoomViewController.m
//  reservationMeetingRoom
//
//  Created by KDG on 2014. 2. 18..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "AddRoomViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface AddRoomViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *organizationField;
@property (nonatomic, weak) IBOutlet UITextField *roomNameField;

@property (nonatomic, strong) BaasioUser *currentUser;
@property (nonatomic, strong) NSString *organization;

- (IBAction)addMeetingRoom;

@end

@implementation AddRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentUser = [BaasioUser currentUser];
    _organization = [_currentUser objectForKey:@"organization"];
    
    [_organizationField setText:_organization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction
- (void)addMeetingRoom {
    BaasioEntity *meetingRoomEntity = [BaasioEntity entitytWithName:@"meeting_rooms"];
    [meetingRoomEntity setObject:_roomNameField.text forKey:@"roomName"];
    [meetingRoomEntity setObject:_currentUser.username forKey:@"owner"];
    [meetingRoomEntity setObject:[_currentUser objectForKey:@"organization"] forKey:@"organization"];
    [meetingRoomEntity setObject:[NSString stringWithFormat:@"%@_%@", _organization, _roomNameField.text] forKey:@"name"];
    
    [meetingRoomEntity saveInBackground:^(BaasioEntity *entity) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"회의실 등록 성공" description:[NSString stringWithFormat:@"%@ 회의실이 등록되었습니다", self.roomNameField.text] type:TWMessageBarMessageTypeSuccess];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failureBlock:^(NSError *error) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"회의실 등록 실패" description:[NSString stringWithFormat:@"%@", error.description] type:TWMessageBarMessageTypeError];
    }];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag != 1002) {
        UIResponder *nextField = [textField.superview viewWithTag:textField.tag+1];
        [nextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self addMeetingRoom];
    }
    
    return NO;
}

@end
