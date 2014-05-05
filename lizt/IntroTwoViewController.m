//
//  IntroTwoViewController.m
//  lizt
//
//  Created by Ziyang Tan on 3/10/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "IntroTwoViewController.h"

@interface IntroTwoViewController ()

@end

@implementation IntroTwoViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Interaction Methods
//Override them if you want them!

-(void)panelDidAppear{
    NSLog(@"Panel Two Did Appear");
    
    //You can use a MYIntroductionPanel subclass to create custom events and transitions for your introduction view
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_intro_two_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)panelDidDisappear{
    NSLog(@"Panel Two Did Disappear");
    
    //Maybe here you want to reset the panel in case someone goes backward and the comes back to your panel
}
@end
