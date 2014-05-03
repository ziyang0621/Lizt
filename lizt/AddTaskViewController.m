//
//  AddTaskViewController.m
//  lizt
//
//  Created by Ziyang Tan on 2/23/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "AddTaskViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CRToast.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


@interface AddTaskViewController () 

@end

@implementation AddTaskViewController {
    NSDateFormatter *formatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.contentSize = CGSizeMake(320.0f, 650.0f);
    _scrollView.frame = CGRectMake(0.0f, 64.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_add_task_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self setUpTextFields];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper function to setup textfields
-(void)setUpTextFields {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];

    _taskNameTextField.delegate = self;
    _taskDueTimeTextField.delegate = self;
    _taskRemindTimeTextField.delegate = self;
    _taskNotesTextView.delegate = self;
    
    [_remindTimeSwitch addTarget:self action:@selector(remindTimeSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    _taskNameTextField.tag = 1;
    _taskDueTimeTextField.tag = 2;
    _taskRemindTimeTextField.tag = 3;
    _taskNotesTextView.tag = 4;
    
    UIToolbar* taskNameToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    taskNameToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithTaskName:)],
                               nil];
    [(UIBarButtonItem*)[taskNameToolbar.items objectAtIndex:1] setTintColor:[UIColor colorWithHex:0x5AC8FB]];
    [taskNameToolbar sizeToFit];
    _taskNameTextField.inputAccessoryView = taskNameToolbar;
    _taskNameTextField.returnKeyType = UIReturnKeyNext;
    
    LiztDatePickerView *dueTimeDatePickerView = [[LiztDatePickerView alloc]initDatePickerView];
    dueTimeDatePickerView.tag = 1;
    dueTimeDatePickerView.delegate = self;
    _taskDueTimeTextField.inputView = dueTimeDatePickerView;
    _taskDueTimeTextField.text = [formatter stringFromDate:[NSDate new]];
    
    LiztDatePickerView *remindTimeDatePickerView = [[LiztDatePickerView alloc]initDatePickerView];
    remindTimeDatePickerView.tag = 2;
    remindTimeDatePickerView.delegate = self;
    _taskRemindTimeTextField.inputView = remindTimeDatePickerView;
    _taskRemindTimeTextField.text = [formatter stringFromDate:[NSDate new]];
    
    UIToolbar* taskNotesToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    taskNotesToolbar.items = [NSArray arrayWithObjects:
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithTaskNotes:)],
                             nil];
    [(UIBarButtonItem*)[taskNotesToolbar.items objectAtIndex:1] setTintColor:[UIColor colorWithHex:0x5AC8FB]];
    [taskNotesToolbar sizeToFit];
    _taskNotesTextView.inputAccessoryView = taskNotesToolbar;
    [_taskNotesTextView.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.3] CGColor]];
    [_taskNotesTextView.layer setBorderWidth:1.0f];
    _taskNotesTextView.layer.cornerRadius = 5;
    _taskNotesTextView.clipsToBounds = YES;
    _taskNotesTextView.text = @"Notes...";
    _taskNotesTextView.textColor = [UIColor colorWithHex:0xC7C7CC];
    
    _taskRemindTimeTextField.hidden = YES;
    _taskNotesLabel.frame = CGRectMake(CGRectGetMinX(_taskNotesLabel.frame), CGRectGetMinY(_taskNotesLabel.frame) - 35.0f, CGRectGetWidth(_taskNotesLabel.frame), CGRectGetHeight(_taskNotesLabel.frame));
     _taskNotesTextView.frame = CGRectMake(CGRectGetMinX(_taskNotesTextView.frame), CGRectGetMinY(_taskNotesTextView.frame) - 35.0f, CGRectGetWidth(_taskNotesTextView.frame), CGRectGetHeight(_taskNotesTextView.frame));
}

-(void)remindTimeSwitchChanged:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    if (switcher.on) {
        _taskRemindTimeTextField.hidden = NO;
        
          _taskNotesLabel.frame = CGRectMake(CGRectGetMinX(_taskNotesLabel.frame), CGRectGetMinY(_taskNotesLabel.frame) + 35.0f, CGRectGetWidth(_taskNotesLabel.frame), CGRectGetHeight(_taskNotesLabel.frame));
          _taskNotesTextView.frame = CGRectMake(CGRectGetMinX(_taskNotesTextView.frame), CGRectGetMinY(_taskNotesTextView.frame) + 35.0f, CGRectGetWidth(_taskNotesTextView.frame), CGRectGetHeight(_taskNotesTextView.frame));
        
        _taskRemindTimeTextField.text = [_taskDueTimeTextField.text copy];
    }
    else {
        _taskRemindTimeTextField.hidden = YES;
        
        _taskNotesLabel.frame = CGRectMake(CGRectGetMinX(_taskNotesLabel.frame), CGRectGetMinY(_taskNotesLabel.frame) - 35.0f, CGRectGetWidth(_taskNotesLabel.frame), CGRectGetHeight(_taskNotesLabel.frame));
        _taskNotesTextView.frame = CGRectMake(CGRectGetMinX(_taskNotesTextView.frame), CGRectGetMinY(_taskNotesTextView.frame) - 35.0f, CGRectGetWidth(_taskNotesTextView.frame), CGRectGetHeight(_taskNotesTextView.frame));
        
        [_taskRemindTimeTextField resignFirstResponder];
    }
}

#pragma mark - LiztDatePicker delegate methods
-(void)datePickerValueDidChanged:(LiztDatePickerView *)datePickerView {
    if (datePickerView.tag == 1) {
        _taskDueTimeTextField.text = [formatter stringFromDate:datePickerView.datePicker.date];
    }
    else {
        _taskRemindTimeTextField.text = [formatter stringFromDate:datePickerView.datePicker.date];
    }
}

-(void)datePickerDidCancel:(LiztDatePickerView *)datePickerView {
    if (datePickerView.tag == 1) {
        _taskDueTimeTextField.text = [formatter stringFromDate:datePickerView.originalDate];
        [_taskDueTimeTextField resignFirstResponder];
    }
    else {
        _taskRemindTimeTextField.text = [formatter stringFromDate:datePickerView.originalDate];
        [_taskRemindTimeTextField resignFirstResponder];
    }
}

-(void)datePickerDidSet:(LiztDatePickerView *)datePickerView {
    if (datePickerView.tag == 1) {
        [_taskDueTimeTextField resignFirstResponder];
    }
    else {
        [_taskRemindTimeTextField resignFirstResponder];
    }
}

#pragma mark - task name accessory view methods 
-(void)doneWithTaskName:(id)sender {
    [_taskNameTextField resignFirstResponder];
}


#pragma mark - task notes accessory view methods
-(void)doneWithTaskNotes:(id)sender {
    [_taskNotesTextView resignFirstResponder];
}

#pragma mark - bar button actions
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate 
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        ((LiztDatePickerView*)_taskDueTimeTextField.inputView).originalDate = [formatter dateFromString:_taskDueTimeTextField.text];
        ((LiztDatePickerView*)_taskDueTimeTextField.inputView).datePicker.date = [formatter dateFromString:_taskDueTimeTextField.text];
    }
    else if (textField.tag == 3) {
        ((LiztDatePickerView*)_taskRemindTimeTextField.inputView).originalDate = [formatter dateFromString:_taskRemindTimeTextField.text];
        ((LiztDatePickerView*)_taskRemindTimeTextField.inputView).datePicker.date = [formatter dateFromString:_taskRemindTimeTextField.text];
    }
}

#pragma mark - UITextViewDelegate
- (void) textViewDidBeginEditing: (UITextView*) textView {
	if ( [_taskNotesTextView.text isEqualToString: @"Notes..."] && [_taskNotesTextView.textColor isEqual:[UIColor colorWithHex:0xC7C7CC]]) {
		_taskNotesTextView.text = nil;
		_taskNotesTextView.textColor = [UIColor blackColor];
	}
}

- (void) textViewDidEndEditing: (UITextView*) textView {
	if (_taskNotesTextView.text && !_taskNotesTextView.text.length ) {
		_taskNotesTextView.text = @"Notes...";
		_taskNotesTextView.textColor = [UIColor colorWithHex:0xC7C7CC];
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _taskNameTextField) {
        [_taskNameTextField resignFirstResponder];
        [_taskDueTimeTextField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)save:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *trimmedString = [_taskNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedString isEqualToString:@""]) {
        NSMutableDictionary *options = [@{
                                  kCRToastTextKey : @"Please enter a task name",
                                  kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor colorWithHex:0xFF5E3A],
                                  kCRToastFontKey : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                                  } mutableCopy];
        
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];
    }
    
    else {
        if ([_taskNotesTextView.textColor isEqual:[UIColor colorWithHex:0xC7C7CC]]) {
            _taskNotesTextView.text = @"";
        }
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"iPhone_add_task_save_pressed"
                                                               value:nil] build]];

        NSDate *dueTime = [NSDate dateWithZeroSeconds:[formatter dateFromString:_taskDueTimeTextField.text]];
        NSDate *remindTime = [NSDate dateWithZeroSeconds:[formatter dateFromString:_taskRemindTimeTextField.text]];
        
        [_delegate controller:self didSaveItemWithName:trimmedString andDueTime: dueTime andRemindTimeOn: _remindTimeSwitch.on andRemindTime: remindTime andNotes:  [_taskNotesTextView.text dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
