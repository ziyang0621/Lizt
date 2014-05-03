//
//  ListCell.h
//  lizt
//
//  Created by Ziyang Tan on 2/23/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

@import UIKit;
#import "SWTableViewCell.h"

@interface ListCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *TaskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *TaskDueTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *TaskTimeDiffLabel;
@property (weak, nonatomic) IBOutlet UIImageView *TaskImageView;
@property (weak, nonatomic) IBOutlet UILabel *TaskImageLabel;
@property (weak, nonatomic) IBOutlet UILabel *TaskWeekdayLabel;
@property (weak, nonatomic) IBOutlet UIView *lowerDivierLine;
@end
