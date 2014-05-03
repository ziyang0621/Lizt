//
//  LiztDatePicker.m
//  lizt
//
//  Created by Ziyang Tan on 4/28/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "LiztDatePickerView.h"

@implementation LiztDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initDatePickerView {
    self = [super initWithFrame: CGRectZero];

    if (self) {
        [[NSBundle mainBundle] loadNibNamed: @"LiztDatePickerView" owner: self options: nil];
        
		[self addSubview: _mainView];
        
        self.frame = CGRectMake(0.0f, 0.0f, _mainView.frame.size.width, _mainView.frame.size.height);
        
        _mainView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        
        _originalDate = _datePicker.date;
        
        [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_morningBtn addTarget:self action:@selector(morningBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_noonBtn addTarget:self action:@selector(noonBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_afterNoonBtn addTarget:self action:@selector(afterNoonBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_nightBtn addTarget:self action:@selector(nightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_nowBtn addTarget:self action:@selector(nowBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_addFifteenBtn addTarget:self action:@selector(addFifteenBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_minusFifteenBtn addTarget:self action:@selector(minusFifteenPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_setBtn addTarget:self action:@selector(setBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setUpView];
        
    }
    
    return self;
}

-(void)setUpView {
    _topDividerLine.backgroundColor = [UIColor colorWithHex:0xD1EEFC andAlpha:0.5f];
    
    _morningBtn.layer.borderWidth = 1.0f;
    _morningBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _morningBtn.clipsToBounds = YES;
    _morningBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _morningBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    
    _noonBtn.layer.borderWidth = 1.0f;
    _noonBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _noonBtn.clipsToBounds = YES;
    _noonBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _noonBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];

    _afterNoonBtn.layer.borderWidth = 1.0f;
    _afterNoonBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _afterNoonBtn.clipsToBounds = YES;
    _afterNoonBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _afterNoonBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    
    _nightBtn.layer.borderWidth = 1.0f;
    _nightBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _nightBtn.clipsToBounds = YES;
    _nightBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _nightBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    
    _minusFifteenBtn.layer.borderWidth = 1.0f;
    _minusFifteenBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _minusFifteenBtn.clipsToBounds = YES;
    _minusFifteenBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _minusFifteenBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    
    _nowBtn.layer.borderWidth = 1.0f;
    _nowBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _nowBtn.clipsToBounds = YES;
    _nowBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _nowBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    
    _addFifteenBtn.layer.borderWidth = 1.0f;
    _addFifteenBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _addFifteenBtn.clipsToBounds = YES;
    _addFifteenBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _addFifteenBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];

    
    _cancelBtn.layer.borderWidth = 1.0f;
    _cancelBtn.layer.borderColor =[UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _cancelBtn.clipsToBounds = YES;
    _cancelBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _cancelBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    
    _setBtn.layer.borderWidth = 1.0f;
    _setBtn.layer.borderColor = [UIColor colorWithHex:0xD1EEFC andAlpha:1.0f].CGColor;
    _setBtn.clipsToBounds = YES;
    _setBtn.tintColor = [UIColor colorWithHex:0x5AC8FB andAlpha:1.0f];
    _setBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];


}

+(LiztDatePickerView*)createDatePicker {
    return nil;
}

-(void)morningBtnPressed:(id)sender {
    [_datePicker setDate:[NSDate getDateWithHour:7 fromDate:_datePicker.date] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)noonBtnPressed:(id)sender {
    [_datePicker setDate:[NSDate getDateWithHour:12 fromDate:_datePicker.date] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)afterNoonBtnPressed:(id)sender {
    [_datePicker setDate:[NSDate getDateWithHour:17 fromDate:_datePicker.date] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)nightBtnPressed:(id)sender {
    [_datePicker setDate:[NSDate getDateWithHour:21 fromDate:_datePicker.date] animated:YES];
    [self.delegate datePickerValueDidChanged:self];

}

-(void)nowBtnPressed:(id)sender {
    [_datePicker setDate:[NSDate new] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)addFifteenBtnPressed:(id)sender {
    [_datePicker setDate:[_datePicker.date dateByAddingTimeInterval:15*60] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)minusFifteenPressed:(id)sender {
    [_datePicker setDate:[_datePicker.date dateByAddingTimeInterval:-15*60] animated:YES];
    [self.delegate datePickerValueDidChanged:self];
}

-(void)datePickerValueChanged:(id)sender {
    [self.delegate datePickerValueDidChanged:self];
}

-(void)cancelBtnPressed:(id)sender {
    [self.delegate datePickerDidCancel:self];
}

-(void)setBtnPressed:(id)sender {
    [self.delegate datePickerDidSet:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
