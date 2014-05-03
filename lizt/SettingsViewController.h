//
//  SettingsViewController.h
//  lizt
//
//  Created by Ziyang Tan on 3/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;

@interface SettingsViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextView *appVersionTextView;
@property (weak, nonatomic) IBOutlet UITextView *rateAppTextView;
@property (weak, nonatomic) IBOutlet UIButton *rateAppButton;
@property (weak, nonatomic) IBOutlet UITextView *tellYourFriendsTextView;
@property (weak, nonatomic) IBOutlet UIButton *shareAppButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end
