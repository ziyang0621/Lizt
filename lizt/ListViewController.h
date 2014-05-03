//
//  ListViewController.h
//  lizt
//
//  Created by Ziyang Tan on 2/22/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

@import UIKit;
#import "AddTaskViewController.h"
#import "EditTaskViewController.h"
#import "SWTableViewCell.h"
#import <iCloud/iCloud.h>

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AddTaskViewControllerDelegate, SWTableViewCellDelegate, iCloudDelegate, EditTaskViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noTaskLabel;
@property (strong, nonatomic) UIAlertView *myAlertView;
@property (nonatomic)BOOL needToConfigiCloud;
@property (nonatomic) NSMutableArray *localList;
@property (nonatomic)BOOL iCloudIsAvailable;
@property (nonatomic)BOOL justLaunch;
@property (nonatomic)BOOL isFirstInstallOrUpdate;

-(void)configiCloud;

@end
