//
//  HostViewController.m
//  lizt
//
//  Created by Ziyang Tan on 2/22/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "HostViewController.h"
#import "ListViewController.h"
#import "SettingsViewController.h"
#import "DejalActivityView.h"
#import "AppDelegate.h"
#import "IntroOneViewController.h"
#import "IntroTwoViewController.h"
#import "IntroThreeViewController.h"
#import "IntroFourViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface HostViewController () <ViewPagerDataSource, ViewPagerDelegate>

@property (nonatomic) NSUInteger numberOfTabs;

@property (nonatomic) ListViewController *listVC;

@property (nonatomic) SettingsViewController *settingsVC;

@property (nonatomic) BOOL runFirstTime;

@property (nonatomic) BOOL newVersion;

@property (nonatomic) BOOL viewIsLoaded;

@end

@implementation HostViewController

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

    self.dataSource = self;
    self.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask:)];
    
    [self appIsRunningForFirstTime];
    
    _viewIsLoaded = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_host_view_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
    self.title = @"Lizt";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdateActivity) name:@"startUpdateActivity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endActivity) name:@"endActivity" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self selectTabAtIndex:0];

    [self performSelector:@selector(loadContent) withObject:nil afterDelay:1.0];
    
    if (_viewIsLoaded && (_runFirstTime || _newVersion)) {
        _viewIsLoaded = NO;
        [self buildIntro];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appIsRunningForFirstTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *previousVersion = [defaults objectForKey:@"appVersion"];
    if (!previousVersion) {
        // first launch
        _runFirstTime = YES;
        
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
    } else if ([previousVersion isEqualToString:currentAppVersion]) {
        // same version
        _runFirstTime = NO;
    } else {
        // other version
        _runFirstTime = NO;
        
        _newVersion = YES;
        
        [defaults setObject:currentAppVersion forKey:@"appVersion"];
        [defaults synchronize];
    }
}

// Activity View
-(void)startUpdateActivity {
    [DejalBezelActivityView activityViewForView:self.navigationController.view withLabel:@"Upating..."];
}

-(void)endActivity {
    [DejalBezelActivityView removeViewAnimated:YES];
}

// Handle add items buttons
- (void)addTask:(id)sender {
    
    AddTaskViewController *addTaskVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTaskViewController"];
    
    addTaskVC.delegate = (ListViewController *)[self viewPager:self contentViewControllerForTabAtIndex:0];
    
    [self presentViewController:addTaskVC animated:YES completion:nil];
}

-(void)buildIntro{
    //Create custom panel with events
    IntroOneViewController *panel1 = [[IntroOneViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"IntroOneViewController"];
    
    IntroTwoViewController *panel2 = [[IntroTwoViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"IntroTwoViewController"];
    
    IntroThreeViewController *panel3 = [[IntroThreeViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"IntroThreeViewController"];
    
     IntroFourViewController *panel4 = [[IntroFourViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"IntroFourViewController"];
    
    if (self.navigationController.view.frame.size.height == 568) {
        panel1.phoneImageView.frame = CGRectMake(panel1.phoneImageView.frame.origin.x, panel1.phoneImageView.frame.origin.y, panel1.phoneImageView.frame.size.width, panel1.phoneImageView.frame.size.height - 25.0f);
        panel2.phoneImageView.frame = CGRectMake(panel2.phoneImageView.frame.origin.x, panel2.phoneImageView.frame.origin.y, panel2.phoneImageView.frame.size.width, panel2.phoneImageView.frame.size.height - 25.0f);
        panel4.phoneImageView.frame = CGRectMake(panel4.phoneImageView.frame.origin.x, panel4.phoneImageView.frame.origin.y, panel4.phoneImageView.frame.size.width, panel4.phoneImageView.frame.size.height - 25.0f);
    }

    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3, panel4];
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    
    [introductionView buildIntroductionWithPanels:panels];
    introductionView.RightSkipButton.hidden = YES;
    introductionView.PageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xD7D7D7];
    introductionView.PageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0x8E8E93];
    introductionView.PageControl.frame = CGRectMake(introductionView.PageControl.frame.origin.x, introductionView.PageControl.frame.origin.y + 5.0f, introductionView.PageControl.frame.size.width, introductionView.PageControl.frame.size.height);
    
    //Add the introduction to your view
    [self.navigationController.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"Introduction did change to panel %d", panelIndex);
    if (panelIndex == 3) {
        introductionView.RightSkipButton.hidden = NO;

        introductionView.RightSkipButton.frame = CGRectMake(CGRectGetMaxX(introductionView.PageControl.frame) - 20.0f, CGRectGetMinY(introductionView.PageControl.frame), 100.0f, CGRectGetHeight(introductionView.PageControl.frame));
        [introductionView.RightSkipButton setTitle:@"Get Started" forState:UIControlStateNormal];
        [introductionView.RightSkipButton setTitleColor:[UIColor colorWithHex:0x0BD318] forState:UIControlStateNormal];
    }
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"Introduction did finish");
    _runFirstTime = NO;
    _newVersion = NO;
    [_listVC configiCloud];
}

#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs {
    
    // Set numberOfTabs
    _numberOfTabs = numberOfTabs;
    
    // Reload data
    [self reloadData];
}

- (void)loadContent {
    self.numberOfTabs = 2;
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return self.numberOfTabs;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    
    if (index == 0) {
        label.text = @"My List";
    }
    else if (index == 1) {
        label.text = @"App Info";
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if (index == 0) {
        if (_listVC == nil) {
            _listVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
            if (_runFirstTime || _newVersion) {
                _listVC.needToConfigiCloud = NO;
                _listVC.isFirstInstallOrUpdate = YES;
            }
            else {
                _listVC.needToConfigiCloud = YES;
            }
        }
        
        return _listVC;
    }
    else  {
        if (_settingsVC == nil) {
            _settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        }
        
        return _settingsVC;
    }
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 40.0;
        case ViewPagerOptionTabOffset:
            return 10.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 140.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}


- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor colorWithHex:0x5AC8FB] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
            return [UIColor colorWithHex:0xF7F7F7 andAlpha:0.3f];
        case ViewPagerContent:
            return [UIColor clearColor];
        default:
            return color;
    }
}


@end
