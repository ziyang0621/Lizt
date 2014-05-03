//
//  LiztDatePicker.h
//  lizt
//
//  Created by Ziyang Tan on 4/28/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LiztDatePickerDelegate;

@interface LiztDatePickerView : UIView

-(id)initDatePickerView;
+(LiztDatePickerView*)createDatePicker;

@property (weak) id<LiztDatePickerDelegate> delegate;
@property (strong, nonatomic) NSDate *originalDate;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *morningBtn;
@property (weak, nonatomic) IBOutlet UIButton *noonBtn;
@property (weak, nonatomic) IBOutlet UIButton *afterNoonBtn;
@property (weak, nonatomic) IBOutlet UIButton *nightBtn;
@property (weak, nonatomic) IBOutlet UIButton *nowBtn;
@property (weak, nonatomic) IBOutlet UIButton *addFifteenBtn;
@property (weak, nonatomic) IBOutlet UIButton *minusFifteenBtn;
@property (weak, nonatomic) IBOutlet UIView *topDividerLine;

@end

@protocol LiztDatePickerDelegate<NSObject>
-(void)datePickerValueDidChanged:(LiztDatePickerView *)datePickerView;
-(void)datePickerDidCancel:(LiztDatePickerView *)datePickerView;
-(void)datePickerDidSet:(LiztDatePickerView *)datePickerView;

@end
