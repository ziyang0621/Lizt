//
//  TrackDataViewController.m
//  lizt
//
//  Created by Ziyang Tan on 5/4/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "TrackDataViewController.h"

@interface TrackDataViewController ()

@end

@implementation TrackDataViewController

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
    
    _completePieChartTitleLabel.text = @"Completion Track";
    [_completePieChartTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    _completePieChartTitleLabel.textColor = [UIColor colorWithHex:0x8E8E93 andAlpha:1.0f];
    
    _slices = [NSMutableArray new];
    
    for(int i = 0; i < 3; i ++)
    {
        NSNumber *one = [NSNumber numberWithInt:3];
        [_slices addObject:one];
    }

    [_completionPieChart setDelegate:self];
    [_completionPieChart setDataSource:self];
    [_completionPieChart setShowPercentage:NO];
    [_completionPieChart setLabelColor:[UIColor colorWithHex:0x1F1F21 andAlpha:1.0f]];
    [_completionPieChart setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithHex:0xA4E786 andAlpha:1.0f],
                       [UIColor colorWithHex:0xFFCC00 andAlpha:1.0f],
                       [UIColor colorWithHex:0xFF5B37 andAlpha:1.0f],nil];

    
    _completeEarlyView.backgroundColor = [UIColor colorWithHex:0xA4E786 andAlpha:1.0f];
    _completeLateView.backgroundColor = [UIColor colorWithHex:0xFFCC00 andAlpha:1.0f];
    _deleteBeforeCompleteView.backgroundColor = [UIColor colorWithHex:0xFF5B37 andAlpha:1.0f];
    
    [_completeEarlyLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    _completeEarlyLabel.textColor = [UIColor colorWithHex:0x8E8E93 andAlpha:1.0f];
    
    [_completeLateLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    _completeLateLabel.textColor = [UIColor colorWithHex:0x8E8E93 andAlpha:1.0f];

    [_deleteBeforeCompleteLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    _deleteBeforeCompleteLabel.textColor = [UIColor colorWithHex:0x8E8E93 andAlpha:1.0f];

    
}

-(void)hideUIElements:(BOOL)hide {
    _completePieChartTitleLabel.hidden = hide;
    _completeEarlyView.hidden = hide;
    _completeEarlyLabel.hidden = hide;
    _completeLateView.hidden = hide;
    _completeLateLabel.hidden = hide;
    _deleteBeforeCompleteView.hidden = hide;
    _deleteBeforeCompleteLabel.hidden = hide;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_track_data_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [_slices removeAllObjects];
    
    int completeEarly = 0;
    int completeLate = 0;
    int deletedBeforeComplete = 0;
    
    if ([[_trackData.completeChart allKeys] count]) {
        for (NSString *key in _trackData.completeChart) {
            NSString *val = [_trackData.completeChart valueForKey:key];
            if ([val isEqualToString:@"YES"]) {
                completeEarly ++;
            }
            else if ([val isEqualToString:@"NO"]) {
                completeLate ++;
            }
            else {
                deletedBeforeComplete ++;
            }
        }
        
        [self hideUIElements:NO];
        _noCompleteDataLabel.hidden = YES;
    }
    else {
        
        [self hideUIElements:YES];
        _noCompleteDataLabel.hidden = NO;
    }
    
    _completeEarlyLabel.text = [NSString stringWithFormat:@"Completed Early ( %d )", completeEarly];
    _completeLateLabel.text = [NSString stringWithFormat:@"Completed Late ( %d )", completeLate];
    _deleteBeforeCompleteLabel.text = [NSString stringWithFormat:@"Deleted Before Complete ( %d )", deletedBeforeComplete];
    
    [_slices addObject:[NSNumber numberWithInt:completeEarly]];
    [_slices addObject:[NSNumber numberWithInt:completeLate]];
    [_slices addObject:[NSNumber numberWithInt:deletedBeforeComplete]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_completionPieChart reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return _slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[_slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [_sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

-(NSString*)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    int percent = (([[_slices objectAtIndex:index] intValue] * 1.0) / [[_trackData.completeChart allKeys] count]) * 100;
    return [NSString stringWithFormat:@"%d%%", percent];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %d",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %d",index);
}



@end
