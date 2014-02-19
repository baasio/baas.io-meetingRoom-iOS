//
//  AddRoomViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 18..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "AddRoomViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface AddRoomViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *organizationField;
@property (nonatomic, strong) IBOutlet UITextField *roomNameField;
@property (nonatomic, strong) IBOutlet UITextField *usersField;

@property (nonatomic, strong) BaasioUser *currentUser;
@property (nonatomic, strong) NSString *organization;

- (IBAction)addMeetingRoom;

@end

@implementation AddRoomViewController

@synthesize currentUser;
@synthesize organization;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [BaasioUser currentUser];
    organization = [currentUser objectForKey:@"organization"];
    
    [self.organizationField setText:organization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction
- (void)addMeetingRoom {
    BaasioEntity *meetingRoomEntity = [BaasioEntity entitytWithName:@"meeting_rooms"];
    [meetingRoomEntity setObject:self.roomNameField.text forKey:@"roomName"];
    [meetingRoomEntity setObject:self.currentUser.username forKey:@"owner"];
    [meetingRoomEntity setObject:[self.currentUser objectForKey:@"organization"] forKey:@"organization"];
    [meetingRoomEntity setObject:[NSString stringWithFormat:@"%@_%@", organization, self.roomNameField.text] forKey:@"name"];
    
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
