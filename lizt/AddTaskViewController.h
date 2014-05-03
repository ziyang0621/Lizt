//
//  AddTaskViewController.h
//  lizt
//
//  Created by Ziyang Tan on 2/23/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiztDatePickerView.h"

@class TPKeyboardAvoidingScrollView;

@protocol AddTaskViewControllerDelegate;

@interface AddTaskViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UITextViewDelegate, LiztDatePickerDelegate>

@property (weak) id<AddTaskViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *taskDueTimeTextField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;
@property (nonatomic, weak) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UISwitch *remindTimeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *taskRemindTimeTextField;
@property (weak, nonatomic) IBOutlet UILabel *taskNotesLabel;

@end

@protocol AddTaskViewControllerDelegate<NSObject>
-(void)controller:(AddTaskViewController *)controller didSaveItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andRemindTimeOn:(BOOL)remindTimeIsOn andRemindTime:(NSDate *)remindTime andNotes:(NSData *)notes;

@end