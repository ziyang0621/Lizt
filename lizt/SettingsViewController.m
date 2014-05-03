//
//  SettingsViewController.m
//  lizt
//
//  Created by Ziyang Tan on 3/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

@import Social;
#import "SettingsViewController.h"
#import "AppConfig.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
	// Do any additional setup after loading the view.
    _scrollView.contentSize = CGSizeMake(320.0f, 568.0f);
    _scrollView.frame = self.view.frame;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_app_info_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    _appVersionTextView.text = [NSString stringWithFormat:@"This is Lizt version %@", APP_VERSION_NUMBER];
    [_appVersionTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    
    _rateAppTextView.text = ASK_FOR_RATING;
    [_rateAppTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    
    _rateAppButton.backgroundColor = [UIColor colorWithHex:0x1AD6FD];
    _rateAppButton.layer.cornerRadius = 4;
    _rateAppButton.clipsToBounds = YES;
    
    _tellYourFriendsTextView.text = TELL_YOUR_FRIENDS;
    [_tellYourFriendsTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    
    _shareAppButton.backgroundColor = [UIColor colorWithHex:0x1AD6FD];
    _shareAppButton.layer.cornerRadius = 4;
    _shareAppButton.clipsToBounds = YES;
}

-(IBAction)rateAppButtonPressed:(id)sender {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"rate_app_button_pressed"
                                                           value:nil] build]];


    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_ID]];
}

- (IBAction)shareAppButtonPressed:(id)sender {
    NSString *actionSheetTitle = @"Choose your social network to share"; //Action Sheet Title
    NSString *other1 = @"Facebook";
    NSString *other2 = @"Twitter";
    NSString *other3 = @"Sina Weibo";
    NSString *cancelTitle = @"Close";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, other3, nil];
    
    [actionSheet showInView:_scrollView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Facebook"]) {
        NSLog(@"Facebook btn pressed");
        [self shareComposer:buttonTitle];
    }
    if ([buttonTitle isEqualToString:@"Twitter"]) {
        NSLog(@"Twitter pressed");
        [self shareComposer:buttonTitle];
    }
    if ([buttonTitle isEqualToString:@"Sina Weibo"]) {
        NSLog(@"Sina Weibo pressed");
        [self shareComposer:buttonTitle];
    }
    if ([buttonTitle isEqualToString:@"Close"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
}

-(void)shareComposer:(NSString*)type {
    SLComposeViewController *shareController;
    if ([type isEqualToString:@"Facebook"]) {
       shareController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    }
    else if ([type isEqualToString:@"Twitter"]) {
        shareController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    }
    else if ([type isEqualToString:@"Sina Weibo"]) {
        shareController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    }
    
    [shareController setInitialText:I_LIKE_THE_APP];
    [shareController addURL:[NSURL URLWithString:APP_STORE_ID]];
    [shareController addImage:[UIImage imageNamed:@"main_view.png"]];

    __block NSString *blockString = [type copy];
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [shareController dismissViewControllerAnimated:YES completion:nil];
        
        switch(result){
            case SLComposeViewControllerResultCancelled:
            default:
            {
                NSLog(@"Cancelled.....");
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:@"cancel_share_app"
                                                                       value:nil] build]];
                break;
            }
            case SLComposeViewControllerResultDone:
            {
                NSLog(@"Posted....");
                
                NSString *GAMsg = [NSString stringWithFormat:@"post_share_app_%@", blockString];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                      action:@"button_press"
                                                                       label:GAMsg
                                                                       value:nil] build]];
                break;
            }
        }};
    [shareController setCompletionHandler:completionHandler];
    [self presentViewController:shareController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
