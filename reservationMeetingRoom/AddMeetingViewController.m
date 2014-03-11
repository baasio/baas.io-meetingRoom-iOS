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

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentUser = [BaasioUser currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _currentDateField = 3;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    
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
    [query setWheres:[NSString stringWithFormat:@"organization = '%@'", [_currentUser objectForKey:@"organization"]]];
    
    [query queryInBackground:^(NSArray *objects) {
        _roomArray = objects;
        [_roomPicker reloadAllComponents];
    } failureBlock:^(NSError *error) {
        NSLog(@"load rooms fail %@", error.description);
    }];
}

- (void)setReservationMessage {
    BaasioPush *push = [[BaasioPush alloc] init];
    BaasioMessage *message = [[BaasioMessage alloc] init];
    
    NSDateComponents *reserve = [[NSDateComponents alloc] init];
    reserve.year = [[_dateField.text substringToIndex:2] integerValue] + 2000;
    reserve.month = [[_dateField.text substringWithRange:NSMakeRange(2, 2)] integerValue];
    reserve.day = [[_dateField.text substringFromIndex:4] integerValue];
    reserve.hour = [[_startTimeField.text substringToIndex:2] integerValue];
    reserve.minute = [[_startTimeField.text substringFromIndex:2] integerValue];
    
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
    [reservationEntity setObject:_startTimeField.text forKey:@"startTime"];
    [reservationEntity setObject:_endTimeField.text forKey:@"endTime"];
    [reservationEntity setObject:_dateField.text forKey:@"date"];
    [reservationEntity setObject:[_currentUser objectForKey:@"name"] forKey:@"userName"];
    [reservationEntity setObject:[_currentUser objectForKey:@"username"] forKey:@"userId"];
    [reservationEntity setObject:_roomNameField.text forKey:@"roomName"];
    [reservationEntity setObject:[_currentUser objectForKey:@"organization"] forKey:@"organization"];
    [reservationEntity setObject:_meetingDescriptionField.text forKey:@"description"];
    
    if ([_addType isEqualToString:@"update"]) {
        [reservationEntity setUuid:[_updateData objectForKey:@"uuid"]];
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
    if ([_startTimeField.text isEqualToString:@""] || [_endTimeField.text isEqualToString:@""] || [_roomNameField.text isEqualToString:@""] || [_dateField.text isEqualToString:@""]) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"파라메터 부족" description:@"모든 칸을 채워주세요" type:TWMessageBarMessageTypeInfo];
        return;
    }
    
    [_dateFormatter setDateFormat:@"HHmm"];
    NSDate *startTime = [_dateFormatter dateFromString:_startTimeField.text];
    NSDate *endTime = [_dateFormatter dateFromString:_endTimeField.text];
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
    [query setWheres:[NSString stringWithFormat:@"organization = '%@' AND roomName = '%@' AND date = '%@'", [_currentUser objectForKey:@"organization"], _roomNameField.text, _dateField.text]];
    
    [query queryInBackground:^(NSArray *objects) {
        NSLog(@"reservationData %@", objects);
        
        // 기존 예약된 정보가 없을 때
        if (objects.count == 0) {
            [self saveReservation];
            
        // 기존 예약된 정보가 있을 때
        } else {
            NSInteger addStartTime = [_startTimeField.text integerValue];
            NSInteger addEndTime = [_endTimeField.text integerValue];
            BOOL duplicatePlag = NO;
            for (NSDictionary *dict in objects) {
                if ([_addType isEqualToString:@"update"] && [[dict objectForKey:@"uuid"] isEqualToString:[_updateData objectForKey:@"uuid"]]) {
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
    if (_currentDateField == 0) {
        [_startTimeField setText:[_dateFormatter stringFromDate:self.datePicker.date]];
    } else if (_currentDateField == 1) {
        [_endTimeField setText:[_dateFormatter stringFromDate:self.datePicker.date]];
    } else if (_currentDateField == 2){
        [_dateField setText:[_dateFormatter stringFromDate:self.datePicker.date]];
    }
    _currentDateField = 3;
    [self datePickerHide];
}

- (void)roomSelected {
    [self roomPickerHide];
}

#pragma mark - UITextFiled Delegate

- (void)roomPickerHide {
    [UIView animateWithDuration:0.3 animations:^{
        [_roomToolBar setFrame:CGRectMake(0, 596, 320, 44)];
        [_roomPicker setFrame:CGRectMake(0, 640, 320, 216)];
    }];
}

- (void)roomPickerShow {
    [UIView animateWithDuration:0.3 animations:^{
        [_roomToolBar setFrame:CGRectMake(0, 346, 320, 44)];
        [_roomPicker setFrame:CGRectMake(0, 370, 320, 216)];
    }];
}

- (void)datePickerHide {
    [UIView animateWithDuration:0.3 animations:^{
        [_dateToolBar setFrame:CGRectMake(0, 596, 320, 44)];
        [_datePicker setFrame:CGRectMake(0, 640, 320, 216)];
    }];
}

- (void)datePickerShow {
    [UIView animateWithDuration:0.3 animations:^{
        [_dateToolBar setFrame:CGRectMake(0, 346, 320, 44)];
        [_datePicker setFrame:CGRectMake(0, 370, 320, 216)];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self dateSelected:nil];
    
    if (textField.tag == 1000) {
        [self roomPickerShow];
        [self datePickerHide];
        [_meetingDescriptionField resignFirstResponder];
        
    } else if (textField.tag == 1002) {
        [self roomPickerHide];
        [self datePickerHide];
        return YES;
        
    } else {
        if (textField.tag == 1001) {
            _currentDateField = 2;
            [_dateFormatter setDateFormat:@"yyMMdd"];
            [_datePicker setDatePickerMode:UIDatePickerModeDate];
            
        } else {
            
            if (textField.tag == 1003) {
                _currentDateField = 0;
            } else if (textField.tag == 1004) {
                _currentDateField = 1;
            }
            [_dateFormatter setDateFormat:@"HHmm"];
            [_datePicker setDatePickerMode:UIDatePickerModeTime];
            [_datePicker setMinuteInterval:30];
        }
        
        [self roomPickerHide];
        [self datePickerShow];
        [_meetingDescriptionField resignFirstResponder];
    }
    
    return NO;
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_roomArray.count > 0) {
        [_roomNameField setText:[[_roomArray objectAtIndex:0] objectForKey:@"roomName"]];
        if ([_addType isEqualToString:@"update"]) {
            [_roomNameField setText:[_updateData objectForKey:@"roomName"]];
            [_dateField setText:[_updateData objectForKey:@"date"]];
            [_startTimeField setText:[_updateData objectForKey:@"startTime"]];
            [_endTimeField setText:[_updateData objectForKey:@"endTime"]];
            [_meetingDescriptionField setText:[_updateData objectForKey:@"description"]];
        }
    }
    return _roomArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dict = [_roomArray objectAtIndex:row];
    
    return [dict objectForKey:@"roomName"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_roomNameField setText:[self pickerView:_roomPicker titleForRow:[_roomPicker selectedRowInComponent:0] forComponent:0]];
}

@end
