//
//  EditTaskViewController.h
//  lizt
//
//  Created by Ziyang Tan on 3/7/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTask.h"
#import "LiztDatePickerView.h"

@class TPKeyboardAvoidingScrollView;

@protocol EditTaskViewControllerDelegate;

@interface EditTaskViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UITextViewDelegate, LiztDatePickerDelegate>

@property (strong, nonatomic) ListTask *task;
@property (weak) id<EditTaskViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *taskDueTimeTextField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UISwitch *remindTimeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *taskRemindTimeTextField;
@property (weak, nonatomic) IBOutlet UILabel *taskNotesLabel;

@end

@protocol EditTaskViewControllerDelegate<NSObject>
-(void)controller:(EditTaskViewController *)controller didUpdateItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andRemindTimeOn:(BOOL)remindTimeIsOn andRemindTime:(NSDate *)remindTime andNotes:(NSData *)notes andOriginalTask: (ListTask*)task;

@end
