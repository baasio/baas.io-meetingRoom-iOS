//
//  AddMeetingViewController.m
//  reservationMeetingRoom
//
//  Created by DGMacBook on 2014. 2. 14..
//  Copyright (c) 2014년 kt. All rights reserved.
//

#import "AddMeetingViewController.h"
#import <baas.io/Baas.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

@interface AddMeetingViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *roomNameField;
@property (nonatomic, strong) IBOutlet UITextField *dateField;
@property (nonatomic, strong) IBOutlet UITextField *startTimeField;
@property (nonatomic, strong) IBOutlet UITextField *endTimeField;
@property (nonatomic, strong) IBOutlet UITextField *meetingDescriptionField;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIPickerView *roomPicker;
@property (nonatomic, strong) IBOutlet UIToolbar *dateToolBar;
@property (nonatomic, strong) IBOutlet UIToolbar *roomToolBar;

@property (nonatomic, strong) NSArray *roomArray;
@property NSInteger currentDateField;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) BaasioUser *currentUser;

- (IBAction)dateSelected:(id)sender;
- (IBAction)roomSelected;
- (IBAction)addReservation;

@end

@implementation AddMeetingViewController

@synthesize roomArray;
@synthesize currentDateField;
@synthesize dateFormatter;
@synthesize currentUser;
@synthesize addType;
@synthesize updateData;

- (void)viewDidLoad {
    [super viewDidLoad];
    currentUser = [BaasioUser currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    currentDateField = 3;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    [self getRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getRooms {
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"meeting_rooms"];
    [query setLimit:10];
    [query setProjectionIn:@"*"];
    [query setOrderBy:@"roomName" order:BaasioQuerySortOrderASC];
    [query setWheres:[NSString stringWithFormat:@"organization = '%@'", [currentUser objectForKey:@"organization"]]];
    
    [query queryInBackground:^(NSArray *objects) {
        roomArray = objects;
        [self.roomPicker reloadAllComponents];
    } failureBlock:^(NSError *error) {
        NSLog(@"load rooms fail %@", error.description);
    }];
}

- (void)setReservationMessage {
    BaasioPush *push = [[BaasioPush alloc] init];
    BaasioMessage *message = [[BaasioMessage alloc] init];
    
    NSDateComponents *reserve = [[NSDateComponents alloc] init];
    reserve.year = [[self.dateField.text substringToIndex:2] integerValue] + 2000;
    reserve.month = [[self.dateField.text substringWithRange:NSMakeRange(2, 2)] integerValue];
    reserve.day = [[self.dateField.text substringFromIndex:4] integerValue];
    reserve.hour = [[self.startTimeField.text substringToIndex:2] integerValue];
    reserve.minute = [[self.startTimeField.text substringFromIndex:2] integerValue];
    
    NSLog(@"reserve %@", reserve);
//    reserve.year = 2014;
//    reserve.month = 2;
//    reserve.day = 26;
//    reserve.hour = 14;
//    reserve.minute = 0;
    
    message.reserve = reserve;
    message.alert = [NSString stringWithFormat:@"%@에서 회의가 곧 시작됩니다.", self.roomNameField.text];
    message.badge = 1;
    message.sound = @"default";
    message.to = [NSMutableArray arrayWithObject:[[BaasioUser currentUser] objectForKey:@"uuid"]];
    
    [push sendPushInBackground:message successBlock:^{
        NSLog(@"푸시 예약 성공");
    } failureBlock:^(NSError *error) {
        NSLog(@"푸시 예약 실패 %@", error);
    }];
}

- (void)saveReservation {
    BaasioEntity *reservationEntity = [BaasioEntity entitytWithName:@"meetings"];
    [reservationEntity setObject:self.startTimeField.text forKey:@"startTime"];
    [reservationEntity setObject:self.endTimeField.text forKey:@"endTime"];
    [reservationEntity setObject:self.dateField.text forKey:@"date"];
    [reservationEntity setObject:[currentUser objectForKey:@"name"] forKey:@"userName"];
    [reservationEntity setObject:[currentUser objectForKey:@"username"] forKey:@"userId"];
    [reservationEntity setObject:self.roomNameField.text forKey:@"roomName"];
    [reservationEntity setObject:[currentUser objectForKey:@"organization"] forKey:@"organization"];
    [reservationEntity setObject:self.meetingDescriptionField.text forKey:@"description"];
    
    if ([self.addType isEqualToString:@"update"]) {
        [reservationEntity setUuid:[self.updateData objectForKey:@"uuid"]];
        [reservationEntity updateInBackground:^(id entity) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 수정 성공" description:@"예약이 수정되었습니다" type:TWMessageBarMessageTypeSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        } failureBlock:^(NSError *error) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 수정 실패" description:@"예약 수정이 실패했습니다" type:TWMessageBarMessageTypeError];
            NSLog(@"%@", error);
        }];
    } else {
        [reservationEntity saveInBackground:^(BaasioEntity *entity) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 성공" description:@"예약이 완료되었습니다" type:TWMessageBarMessageTypeSuccess];
            [self.navigationController popViewControllerAnimated:YES];
            [self setReservationMessage];
        } failureBlock:^(NSError *error) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 실패" description:@"예약이 실패했습니다" type:TWMessageBarMessageTypeError];
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - IBAction
- (void)addReservation {
    if ([self.startTimeField.text isEqualToString:@""] || [self.endTimeField.text isEqualToString:@""] || [self.roomNameField.text isEqualToString:@""] || [self.dateField.text isEqualToString:@""]) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"파라메터 부족" description:@"모든 칸을 채워주세요" type:TWMessageBarMessageTypeInfo];
        return;
    }
    
    [dateFormatter setDateFormat:@"HHmm"];
    NSDate *startTime = [dateFormatter dateFromString:self.startTimeField.text];
    NSDate *endTime = [dateFormatter dateFromString:self.endTimeField.text];
    switch ([startTime compare:endTime]) {
        case NSOrderedDescending:
        case NSOrderedSame:
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"시간 설정이 잘못되었습니다" description:@"시작시간은 끝시간보다 같거나 뒤일 수 없습니다" type:TWMessageBarMessageTypeInfo];
            return;
            
        default:
            break;
    }
    
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"meetings"];
    [query setProjectionIn:@"*"];
    [query setOrderBy:@"startTime" order:BaasioQuerySortOrderASC];
    [query setWheres:[NSString stringWithFormat:@"organization = '%@' AND roomName = '%@' AND date = '%@'", [currentUser objectForKey:@"organization"], self.roomNameField.text, self.dateField.text]];
    
    [query queryInBackground:^(NSArray *objects) {
        NSLog(@"reservationData %@", objects);
        
        // 기존 예약된 정보가 없을 때
        if (objects.count == 0) {
            [self saveReservation];
            
        // 기존 예약된 정보가 있을 때
        } else {
            NSInteger addStartTime = [self.startTimeField.text integerValue];
            NSInteger addEndTime = [self.endTimeField.text integerValue];
            BOOL duplicatePlag = NO;
            for (NSDictionary *dict in objects) {
                if ([self.addType isEqualToString:@"update"] && [[dict objectForKey:@"uuid"] isEqualToString:[self.updateData objectForKey:@"uuid"]]) {
                    continue;
                }
                NSInteger startTime = [[dict objectForKey:@"startTime"] integerValue];
                NSInteger endTime = [[dict objectForKey:@"endTime"] integerValue];
                
                if ((startTime <= addStartTime && addStartTime < endTime) || (startTime < addEndTime && addEndTime <= endTime)) {
                    duplicatePlag = YES;
                }
            }
            
            if (duplicatePlag) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"예약 실패" description:@"이미 예약된 시간입니다" type:TWMessageBarMessageTypeError];
            } else {
                [self saveReservation];
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"load rooms fail %@", error.description);
    }];
}

- (void)dateSelected:(id)sender {
    if (currentDateField == 0) {
        [self.startTimeField setText:[dateFormatter stringFromDate:self.datePicker.date]];
    } else if (currentDateField == 1) {
        [self.endTimeField setText:[dateFormatter stringFromDate:self.datePicker.date]];
    } else if (currentDateField == 2){
        [self.dateField setText:[dateFormatter stringFromDate:self.datePicker.date]];
    }
    currentDateField = 3;
    [self datePickerHide];
}

- (void)roomSelected {
    [self roomPickerHide];
}

#pragma mark - UITextFiled Delegate

- (void)roomPickerHide {
    [UIView animateWithDuration:0.3 animations:^{
        [self.roomToolBar setFrame:CGRectMake(0, 596, 320, 44)];
        [self.roomPicker setFrame:CGRectMake(0, 640, 320, 216)];
    }];
}

- (void)roomPickerShow {
    [UIView animateWithDuration:0.3 animations:^{
        [self.roomToolBar setFrame:CGRectMake(0, 346, 320, 44)];
        [self.roomPicker setFrame:CGRectMake(0, 370, 320, 216)];
    }];
}

- (void)datePickerHide {
    [UIView animateWithDuration:0.3 animations:^{
        [self.dateToolBar setFrame:CGRectMake(0, 596, 320, 44)];
        [self.datePicker setFrame:CGRectMake(0, 640, 320, 216)];
    }];
}

- (void)datePickerShow {
    [UIView animateWithDuration:0.3 animations:^{
        [self.dateToolBar setFrame:CGRectMake(0, 346, 320, 44)];
        [self.datePicker setFrame:CGRectMake(0, 370, 320, 216)];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self dateSelected:nil];
    
    if (textField.tag == 1000) {
        [self roomPickerShow];
        [self datePickerHide];
        [self.meetingDescriptionField resignFirstResponder];
        
    } else if (textField.tag == 1002) {
        [self roomPickerHide];
        [self datePickerHide];
        return YES;
        
    } else {
        if (textField.tag == 1001) {
            currentDateField = 2;
            [dateFormatter setDateFormat:@"yyMMdd"];
            [self.datePicker setDatePickerMode:UIDatePickerModeDate];
            
        } else {
            
            if (textField.tag == 1003) {
                currentDateField = 0;
            } else if (textField.tag == 1004) {
                currentDateField = 1;
            }
            [dateFormatter setDateFormat:@"HHmm"];
            [self.datePicker setDatePickerMode:UIDatePickerModeTime];
            [self.datePicker setMinuteInterval:30];
        }
        
        [self roomPickerHide];
        [self datePickerShow];
        [self.meetingDescriptionField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (roomArray.count > 0) {
        [self.roomNameField setText:[[roomArray objectAtIndex:0] objectForKey:@"roomName"]];
        if ([addType isEqualToString:@"update"]) {
            [self.roomNameField setText:[self.updateData objectForKey:@"roomName"]];
            [self.dateField setText:[self.updateData objectForKey:@"date"]];
            [self.startTimeField setText:[self.updateData objectForKey:@"startTime"]];
            [self.endTimeField setText:[self.updateData objectForKey:@"endTime"]];
            [self.meetingDescriptionField setText:[self.updateData objectForKey:@"description"]];
        }
    }
    return roomArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dict = [roomArray objectAtIndex:row];
    
    return [dict objectForKey:@"roomName"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.roomNameField setText:[self pickerView:self.roomPicker titleForRow:[self.roomPicker selectedRowInComponent:0] forComponent:0]];
}

@end
