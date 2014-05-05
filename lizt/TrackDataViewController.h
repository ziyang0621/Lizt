//
//  TrackDataViewController.h
//  lizt
//
//  Created by Ziyang Tan on 5/4/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "TrackData.h"

@interface TrackDataViewController : UIViewController <XYPieChartDelegate, XYPieChartDataSource>

@property (weak, nonatomic) IBOutlet UILabel *completePieChartTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noCompleteDataLabel;
@property (weak, nonatomic) IBOutlet XYPieChart *completionPieChart;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) TrackData *trackData;
@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) NSArray        *sliceColors;
@property (weak, nonatomic) IBOutlet UIView *completeEarlyView;
@property (weak, nonatomic) IBOutlet UIView *completeLateView;
@property (weak, nonatomic) IBOutlet UIView *deleteBeforeCompleteView;
@property (weak, nonatomic) IBOutlet UILabel *completeEarlyLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLateLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteBeforeCompleteLabel;
@end
