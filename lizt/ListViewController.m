//
//  ListViewController.m
//  lizt
//
//  Created by Ziyang Tan on 2/22/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "ListViewController.h"
#import "ListCell.h"
#import "MHPrettyDate.h"
#import "ListTask.h"
#import "DejalActivityView.h"
#import "ListDoc.h"
#import "ListDB.h"
#import "AppConfig.h"
#import "NSDate+HumanizedTime.h"
#import "CRToast.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ListViewController () {
 
UIRefreshControl *refreshControl;
    
}

@property NSDateFormatter *formatter;
@property NSMutableArray *fileNameList;
@property BOOL viewIsLoaded;
@property BOOL isUpdating;
@property BOOL isRetrieving;
@property int updateCounter;
@property BOOL wasUnavailable;
@property BOOL toastCompleted;
@property BOOL toastIsFirstShown;

@end

@implementation ListViewController

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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _formatter = [[NSDateFormatter alloc] init];
    
    // Setup File List
    if (_fileNameList == nil) _fileNameList = [NSMutableArray array];
    
    // Setup iCloud
    iCloud *cloud = [iCloud sharedCloud]; // This will help to begin the sync process and register for document updates
    [cloud setDelegate:self]; // Set this if you plan to use the delegate
    [cloud setVerboseLogging:YES]; // We want detailed feedback about what's going on with iCloud, this is OFF by default
    
    [self cleanAllScheduledAlarms];
    
    _viewIsLoaded = YES;
    _justLaunch = YES;
    _toastIsFirstShown = YES;
    
    _localList = [ListDB loadDocs];
    
    [_formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];
    
    for (int i = 0; i < _localList.count; i++) {
        ListDoc *item = (ListDoc*)[_localList objectAtIndex:i];
        NSLog(@"the item name:%@, %@, %@", item.data.taskName, [_formatter stringFromDate: item.data.taskDueTime], [_formatter stringFromDate:item.data.lastModifiedDate]);
    }
    [self sortLocalList];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"iphone_list_view_screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
    if (_needToConfigiCloud && _viewIsLoaded) {
        _viewIsLoaded = NO;
        [self configiCloud];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

-(void)configiCloud {
    if ([[iCloud sharedCloud] checkCloudAvailability] == NO) {
        NSLog(@"icloud is not available");
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"iPhone_icloud_is_not_available_in_view_will_appear"
                                                               value:nil] build]];
        
        
        if (_isFirstInstallOrUpdate) {
            _myAlertView = [[UIAlertView alloc] initWithTitle:@"Setup iCloud" message:SETUP_ICLOUD delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [_myAlertView show];
        }
        
        _wasUnavailable = YES;
        UIApplication *app = [UIApplication sharedApplication];
        [[app.delegate window] setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
        
        _iCloudIsAvailable = NO;
        
        if (_toastIsFirstShown || _toastCompleted) {
            [self showTodayTasks];
        }
    }
    else {
        NSLog(@"icloud is available");
        _iCloudIsAvailable = YES;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkiCloudAvailability) name:@"checkAvailability" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateList) name:@"updateList" object:nil];
    
    //IMPORTANT: retrieve list, when app is first install or delete then reinstall
    if (_viewIsLoaded) {
        _viewIsLoaded = NO;
        _isRetrieving = NO;
        if (_iCloudIsAvailable) {
            [self localToRetrieveData];
        }
    }
}

-(void)checkiCloudAvailability {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    if ([[iCloud sharedCloud] checkCloudAvailability] == NO) {
        NSLog(@"icloud is not available");
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"button_press"
                                                               label:@"iPhone_icloud_is_not_available_in_check_availability"
                                                               value:nil] build]];

        _iCloudIsAvailable = NO;
        _wasUnavailable = YES;
        if (_toastIsFirstShown || _toastCompleted) {
            [self showTodayTasks];
        }
    }
    else {
        NSLog(@"icloud is available");
        if (_wasUnavailable) {
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"iPhone_icloud_is_available_after_setup"
                                                                   value:nil] build]];
            
            [_myAlertView dismissWithClickedButtonIndex:0 animated:NO];
            [[iCloud sharedCloud] init];
            [[iCloud sharedCloud] setDelegate:self];
            _iCloudIsAvailable = YES;
            _wasUnavailable = NO;
            [self localToRetrieveData];
        }
        else {
            [[iCloud sharedCloud] updateFiles];
            if (_toastIsFirstShown || _toastCompleted) {
                [self showTodayTasks];
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateList {
    [self sortLocalList];
    [_tableView reloadData];
}


#pragma mark - iCloud Methods
- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    if (!cloudIsAvailable) {
        NSLog(@"iCloud is no longer available. Make sure that you are signed into a valid iCloud account.");
        _iCloudIsAvailable = NO;
    }
    else {
        NSLog(@"iCloud is available in delegate");
        _iCloudIsAvailable = YES;
    }
}

-(void)iCloudFileUpdateDidBegin {
    NSLog(@"update did begin");
}

-(void)iCloudFileUpdateDidEnd {
    NSLog(@"update did end");
}


- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
    // Get the query results
    NSLog(@"Files did change: %@", fileNames);
    
    _fileNameList = fileNames; // A list of the file names
    
    if (_fileNameList.count == 0) {
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }
    
    if (_isUpdating) {
        _updateCounter ++;
        if (_updateCounter >= 2) {
            _updateCounter = 0;
            _isUpdating = NO;
        }
    }
    else  {
        if (!_isRetrieving && !_viewIsLoaded) {
            NSLog(@"start refreshing......");
            if (_justLaunch) {
                [self localToRetrieveData];
            }
            else {
                [self retrieveData];
            }
        }
    }
}

-(BOOL)containFile:(NSString*)fileName {

    for (ListDoc *doc in _localList) {
        if ([doc.data.fileName isEqualToString:fileName]) {
            return YES;
        }
    }
    return NO;
}

-(int)indexOfDoc:(NSString*)fileName {
    int i = 0;
    for (ListDoc *doc in _localList) {
        if ([doc.data.fileName isEqualToString:fileName]) {
            return i;
        }
        i++;
    }
    return -1;
}

-(void)localToRetrieveData {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdateActivity" object:nil];

    _isRetrieving = YES;
    __block int i = 0;

    NSArray *tempList = [NSMutableArray arrayWithArray:_fileNameList];

    if (!tempList.count) {
        [self sortLocalList];
        [self localToSaveData];
    }
    
    for (NSString *fileName in tempList) {
        NSLog(@"fileName:%@, size:%d, exist:%d", fileName,[[iCloud sharedCloud] fileSize:fileName], [[iCloud sharedCloud] doesFileExistInCloud:fileName]);
        
        if ([[iCloud sharedCloud] doesFileExistInCloud:fileName]) {
            [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
                if (!error) {
                    
                    ListTask *item = (ListTask*)[NSKeyedUnarchiver unarchiveObjectWithData:documentData];
                    
                    if ([self containFile:fileName]) {
                        int index = [self indexOfDoc:fileName];
                        if ([item.lastModifiedDate compare: ((ListDoc*)[_localList objectAtIndex:index]).data.lastModifiedDate ] == NSOrderedDescending) {
                            ((ListDoc*)[_localList objectAtIndex:index]).data = item;
                            [((ListDoc*)[_localList objectAtIndex:index]) saveData];
                        }
                    }
                    else {
                        ListDoc *doc = [[ListDoc alloc] init];
                        doc.data = item;
                        [doc saveData];
                        [_localList addObject:doc];
                    }
                    
                    [cloudDocument closeWithCompletionHandler:^(BOOL success) {
                        if (success) {
                            i ++;
                            if (i == tempList.count) {
                                [self sortLocalList];
                                [self localToSaveData];
                            }
                        }
                    }];
                }
                else {
                    NSLog(@"retrieve data error");
                    _isRetrieving = NO;
                }
            }];
        }
        else {
            i ++;
            if (i == tempList.count) {
                [self sortLocalList];
                [self localToSaveData];
              
            }
        }
    }
}

-(void)localToSaveData {
    
    __block int i = 0;
    if (!_localList.count) {
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        _isRetrieving = NO;
        _justLaunch = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
        if (_toastIsFirstShown || _toastCompleted) {
            [self showTodayTasks];
        }
    }
    for (ListDoc *doc in _localList) {
        NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:doc.data];

        [[iCloud sharedCloud] saveAndCloseDocumentWithName:doc.data.fileName withContent:fileData completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
            if (!error) {
                NSLog(@"iCloud Document, %@ launch saved successfully", cloudDocument.fileURL.lastPathComponent);
                
                i ++;
                if (i == _localList.count) {
                    [self.tableView reloadData];
                    [refreshControl endRefreshing];
                    _isRetrieving = NO;
                    _justLaunch = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
                    if (_toastIsFirstShown || _toastCompleted) {
                        [self showTodayTasks];
                    }
                }
            
            }
            else {
                NSLog(@"iCloud Document save error: %@", error);
            }
        }];
    }
}

-(void)deleteAllDoc {
    for (ListDoc *doc in _localList) {
        [doc deleteDoc];
    }
}

-(void)retrieveData {
    _isRetrieving = YES;
    __block int i = 0;
    
    [self deleteAllDoc];
    _localList = [NSMutableArray array];
    NSArray *tempList = [NSMutableArray arrayWithArray:_fileNameList];
    if (!tempList.count) {
        [self sortLocalList];
        
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        
        _isRetrieving = NO;
    }
    for (NSString *fileName in tempList) {
        NSLog(@"fileName:%@, size:%d, exist:%d", fileName,[[iCloud sharedCloud] fileSize:fileName], [[iCloud sharedCloud] doesFileExistInCloud:fileName]);
        
        if ([[iCloud sharedCloud] doesFileExistInCloud:fileName]) {
            [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
                if (!error) {
                    
                    ListTask *item = (ListTask*)[NSKeyedUnarchiver unarchiveObjectWithData:documentData];
                    
                    ListDoc *doc = [[ListDoc alloc] init];
                    doc.data = item;
                    [doc saveData];
                    [_localList addObject:doc];
                    
                    [cloudDocument closeWithCompletionHandler:^(BOOL success) {
                        if (success) {
                            i ++;
                            if (i == tempList.count) {
                                [self sortLocalList];
                                
                                [self.tableView reloadData];
                                [refreshControl endRefreshing];
                                _isRetrieving = NO;
                            }
                        }
                    }];
                }
                else {
                    NSLog(@"retrieve data error");
                    _isRetrieving = NO;
                }
            }];
        }
        else {
            i ++;
            if (i == tempList.count) {
                [self sortLocalList];
                
                [self.tableView reloadData];
                [refreshControl endRefreshing];
                _isRetrieving = NO;
            }
        }
    }
}


-(void)sortLocalList {
    id mySort = ^(ListDoc *obj1, ListDoc *obj2) {
        return [obj1.data.taskDueTime compare: obj2.data.taskDueTime];
    };

    NSArray *sortedDates = [_localList sortedArrayUsingComparator:mySort];
    _localList = [NSMutableArray arrayWithArray:sortedDates];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_localList.count) {
        _noTaskLabel.hidden = YES;
    }
    else {
        _noTaskLabel.hidden = NO;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return [self numberOfTasksInThePast];
            break;
        case 1:
            return [self numberOfTasksToday];
            break;
        case 2:
            return [self numberOfTasksTomorrow];
            break;
        default:;
            return [self numberOfTasksUpcoming];
            break;
    }
    return _localList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (![self numberOfTasksInThePast]) {
                return 0.0f;
            }
            return 25.0f;
            break;
        case 1:
            if (![self numberOfTasksToday]) {
                return 0.0f;
            }
            return 25.0f;
            break;
        case 2:
            if (![self numberOfTasksTomorrow]) {
                return 0.0f;
            }
            return 25.0f;
            break;
        default:;
            if (![self numberOfTasksUpcoming]) {
                return 0.0f;
            }
            return 25.0f;
            break;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 	UIView*	headerView;
    UILabel* headerTitleLabel;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          0,
                                                          CGRectGetWidth(_tableView.frame ),
                                                          _tableView.sectionHeaderHeight)];
    
    headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                 0,
                                                                 CGRectGetWidth(_tableView.frame ) - 40,
                                                                 _tableView.sectionHeaderHeight)];
    
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.textColor = [UIColor colorWithHex:0x5AC8FB];
    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    
    switch (section) {
        case 0:
            headerTitleLabel.text = @"Past";
            break;
        case 1:
            headerTitleLabel.text = @"Today";
            break;
        case 2:
            headerTitleLabel.text = @"Tomorrow";
            break;
        default:;
            headerTitleLabel.text = @"Upcoming";
            break;
    }
    
    headerView.backgroundColor = [UIColor colorWithHex:0xF7F7F7 andAlpha:1.0f] ;
    [headerView addSubview:headerTitleLabel];
    
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell selected at index path %d:%d", indexPath.section, indexPath.row);
    
    EditTaskViewController *editTaskVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditTaskViewController"];
    
    editTaskVC.delegate = self;
    
    int preRows = [self findPreRows:indexPath];
    
    editTaskVC.task = ((ListDoc *)[_localList objectAtIndex:indexPath.row + preRows]).data;
    
    [self presentViewController:editTaskVC animated:YES completion:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ListCell";

    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSUInteger count = _localList.count;
    
    if (indexPath.row < count) {

        ListTask *task;
        ListDoc *doc = (ListDoc *)[_localList objectAtIndex:indexPath.row + [self findPreRows:indexPath]];
        
        task = doc.data;
        
        
        cell.TaskNameLabel.text = task.taskName;
        cell.TaskDueTimeLabel.textColor = [UIColor colorWithHex:0x8E8E93];
        
        [_formatter setDateFormat:@"hh:mm a"];
        

        
        NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:units fromDate:task.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];
        [_formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];
        
        NSLog(@"task remind time %@, %@", task.taskName, [_formatter stringFromDate:task.taskRemindTime]);
        
        if ([myDate isEqualToDate:today]) {
            cell.TaskDueTimeLabel.textColor = [UIColor colorWithHex:0x5AC8FB];
        }
        cell.TaskDueTimeLabel.text = [_formatter stringFromDate:task.taskDueTime];
        
        cell.TaskImageView.backgroundColor = [UIColor whiteColor];
        cell.TaskImageView.layer.cornerRadius = cell.TaskImageView.frame.size.height/2;
        cell.TaskImageView.layer.masksToBounds = YES;
        cell.TaskImageView.layer.borderWidth = 1.0f;
        
        if (task.isCompleted) {
            cell.TaskImageView.layer.borderColor = [UIColor colorWithHex:0x0BD318].CGColor;
            cell.TaskImageLabel.textColor = [UIColor colorWithHex:0x0BD318];
            cell.TaskImageLabel.text = @"Completed";
            
            [self cancelScheduleAlarm:task.fileName];
        }
        else {
            cell.accessoryView = UITableViewCellAccessoryNone;
            //Task is overdue
            if ([task.taskDueTime compare:[NSDate new]] == NSOrderedAscending || [task.taskDueTime compare:[NSDate new]] == NSOrderedSame) {
                
                cell.TaskImageView.layer.borderColor = [UIColor colorWithHex:0xFF1300].CGColor;
                cell.TaskImageLabel.textColor = [UIColor colorWithHex:0xFF1300];
                cell.TaskImageLabel.text = @"Overdue";
                
                [self cancelScheduleAlarm:task.fileName];
                
                if (task.taskRemindTime && ([task.taskRemindTime compare:[NSDate new]] == NSOrderedDescending)) {
                    [self setUpRemindAlarm:task];
                }
            }
            //Task is not completed and its in the future
            else {
                
                cell.TaskImageView.layer.borderColor = [UIColor colorWithHex:0xFFCC00].CGColor;
                cell.TaskImageLabel.textColor = [UIColor colorWithHex:0xFFCC00];
                cell.TaskImageLabel.text = @"Active";

                [self cancelScheduleAlarm:task.fileName];
                [self setUpNotifAlarm:task];
                
                if (task.taskRemindTime && ([task.taskRemindTime compare:[NSDate new]] == NSOrderedDescending)) {
                    [self setUpRemindAlarm:task];
                }
            }
        }
    
        //If a task is in the past
        if ([task.taskDueTime compare:[NSDate new]] == NSOrderedAscending || [task.taskDueTime compare:[NSDate new]] == NSOrderedSame) {
            cell.TaskTimeDiffLabel.text = [task.taskDueTime stringWithHumanizedTimeDifference:NSDateHumanizedSuffixAgo withFullString:YES];
        }
        //If a task in in the future
        else {
            cell.TaskTimeDiffLabel.text = [task.taskDueTime stringWithHumanizedTimeDifference:NSDateHumanizedSuffixLeft withFullString:YES];
            
        }
        
        [_formatter setDateFormat:@"EEEE"];
        cell.TaskWeekdayLabel.text = [_formatter stringFromDate:task.taskDueTime];
        
        cell.TaskNameLabel.numberOfLines = 0;
        
        [cell.TaskNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f]];
        [cell.TaskDueTimeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        [cell.TaskTimeDiffLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14.0f]];
        [cell.TaskWeekdayLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:12.0f]];
        [cell.TaskImageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
        
        cell.leftUtilityButtons = [self leftButtons:task];
        cell.delegate = self;
    }
    
    cell.lowerDivierLine.backgroundColor = [UIColor colorWithHex:0xD7D7D7 andAlpha:0.5f];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    return cell;
}

-(int)numberOfTasksInThePast {
    int counter = 0;
    
    NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
    
    components = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    components.day = components.day-1;
    NSDate* yesterdayMidnight = [[NSCalendar currentCalendar] dateFromComponents:components];

    
    for (ListDoc *doc in _localList) {
        components = [cal components:units fromDate:doc.data.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];
        
        if ([myDate compare:yesterdayMidnight] != NSOrderedDescending) {
            counter ++;
        }
    }

    NSLog(@"number of task in the past: %d", counter);
    return counter;
}

-(int)numberOfTasksToday {
    int counter = 0;
    
    NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    for (ListDoc *doc in _localList) {
        components = [cal components:units fromDate:doc.data.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];
        
        if ([myDate isEqualToDate:today]) {
            counter ++;
        }
    }
    
    NSLog(@"number of task today: %d", counter);
    return counter;
}



-(int)numberOfTasksTomorrow {
    int counter = 0;
    
    NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
    
    components = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    components.day = components.day+1;
    NSDate* tomorrowMidnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    
    for (ListDoc *doc in _localList) {
        components = [cal components:units fromDate:doc.data.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];
        
        if ([myDate isEqualToDate:tomorrowMidnight]) {
            counter ++;
        }
    }
    
    NSLog(@"number of task tomorrow: %d", counter);
    return counter;
}

-(int)numberOfTasksUpcoming {
    int counter = 0;
    
    NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
    
    components = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date]];
    components.day = components.day+1;
    NSDate* tomorrowMidnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    
    for (ListDoc *doc in _localList) {
        components = [cal components:units fromDate:doc.data.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];
        
        if ([myDate compare:tomorrowMidnight] == NSOrderedDescending) {
            counter ++;
        }
    }
    
    NSLog(@"number of task upcoming: %d", counter);
    return counter;
}

-(void)showTodayTasks {
    _toastIsFirstShown = NO;
    _toastCompleted = NO;
    
    NSCalendarUnit units = NSEraCalendarUnit| NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:units fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    int totalTasks = 0;
    
    for (ListDoc *doc in _localList) {
        components = [cal components:units fromDate:doc.data.taskDueTime];
        NSDate *myDate = [cal dateFromComponents:components];

        if ([myDate isEqualToDate:today]) {
            totalTasks ++;
        }
    }
    
    NSString *msg;
    if (totalTasks > 1) {
        msg = [NSString stringWithFormat:@"%d tasks total today", totalTasks];
    }
    else if (totalTasks == 1) {
        msg = [NSString stringWithFormat:@"Only %d task today", totalTasks];
    }
    else {
        msg = [NSString stringWithFormat:@"No task today"];
    }
    
    NSMutableDictionary *options = [@{
                                      kCRToastTextKey : msg,
                                      kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor colorWithHex:0x5AC8FB],
                                      kCRToastFontKey : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                      kCRToastTimeIntervalKey : @(2.0f)
                                      } mutableCopy];
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                    _toastCompleted = YES;
                                }];

}


- (NSArray *)leftButtons:(ListTask*)task {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if (!task.isCompleted) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithHex:0x87FC70] title:@"Complete"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithHex:0xFF5E3A] title:@"Delete"];
    }
    else {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithHex:0xFFDB4C] title:@"Undo"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithHex:0xFF5E3A] title:@"Delete"];
    }
    return rightUtilityButtons;
}

#pragma mark - AddTaskViewControllerDelegate
-(void)controller:(AddTaskViewController *)controller didSaveItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andRemindTimeOn:(BOOL)remindTimeIsOn andRemindTime:(NSDate *)remindTime andNotes:(NSData *)notes {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdateActivity" object:nil];
    
    NSString *newFileName = [self generateFileNameWithExtension:@"txt"];
    
    ListTask *task = [[ListTask alloc] init];
    task.taskName = [name copy];
    task.taskDueTime = dueTime;
    task.taskNotes = notes;
    task.fileName = [newFileName copy];
    
    if (remindTimeIsOn) {
        task.taskRemindTime = remindTime;
    }
    
    [self saveListItem:task];
}

//-(void)controller:(AddTaskViewController *)controller didSaveItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andNotes:(NSData *)notes {
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdateActivity" object:nil];
//    
//    NSString *newFileName = [self generateFileNameWithExtension:@"txt"];
//    
//    ListTask *task = [[ListTask alloc] init];
//    task.taskName = [name copy];
//    task.taskDueTime = dueTime;
//    task.taskNotes = notes;
//    task.fileName = [newFileName copy];
//    
//    [self saveListItem:task];
//}

#pragma mark - EditTaskViewControllerDelegate
-(void)controller:(EditTaskViewController *)controller didUpdateItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andRemindTimeOn:(BOOL)remindTimeIsOn andRemindTime:(NSDate *)remindTime andNotes:(NSData *)notes andOriginalTask:(ListTask *)task{
    
        NSString *fileName = [task.fileName copy];
        
        for (int i = 0; i < _localList.count; i++) {
            if ([((ListDoc *)[_localList objectAtIndex:i]).data.fileName isEqualToString:fileName]) {
                [((ListDoc*)[_localList objectAtIndex:i]) deleteDoc];
                [_localList removeObjectAtIndex:i];
                break;
            }
        }
        
        ListTask *newTask = [[ListTask alloc] init];
        newTask.taskName = [name copy];
        newTask.taskDueTime = dueTime;
        newTask.taskNotes = notes;
        newTask.fileName = [fileName copy];
        
        if (remindTimeIsOn) {
            newTask.taskRemindTime = remindTime;
        }
        
        [self saveListItem:newTask];
}


//-(void)controller:(EditTaskViewController *)controller didUpdateItemWithName:(NSString *)name andDueTime:(NSDate *)dueTime andNotes:(NSData *)notes andOriginalTask:(ListTask *)task
//{
//    if (![name isEqualToString:task.taskName] || ![dueTime isEqualToDate:task.taskDueTime] || ![notes isEqualToData:task.taskNotes]) {
//        
//        NSString *fileName = [task.fileName copy];
//        
//        for (int i = 0; i < _localList.count; i++) {
//            if ([((ListDoc *)[_localList objectAtIndex:i]).data.fileName isEqualToString:fileName]) {
//                [((ListDoc*)[_localList objectAtIndex:i]) deleteDoc];
//                [_localList removeObjectAtIndex:i];
//                break;
//            }
//        }
//        
//        ListTask *newTask = [[ListTask alloc] init];
//        newTask.taskName = [name copy];
//        newTask.taskDueTime = dueTime;
//        newTask.taskNotes = notes;
//        newTask.fileName = [fileName copy];
//        
//        [self saveListItem:newTask];
//    }
//}


-(void)saveListItem:(ListTask *)task{
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:task];
    
    if (_iCloudIsAvailable) {
        [[iCloud sharedCloud] saveAndCloseDocumentWithName:task.fileName withContent:fileData completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
            if (!error) {
                NSLog(@"iCloud Document, %@ saved successfully", cloudDocument.fileURL.lastPathComponent);
                
                _isUpdating = YES;
                _updateCounter = 0;
                
                task.lastModifiedDate = [NSDate new];
                ListDoc *doc = [[ListDoc alloc] init];
                doc.data = task;
                
                [_localList addObject:doc];
                
                [self sortLocalList];
                [_tableView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
            }
            else {
                NSLog(@"iCloud Document save error: %@", error);
            }
        }];
    }
    else {
        task.lastModifiedDate = [NSDate new];
        
        ListDoc *doc = [[ListDoc alloc] init];
        doc.data = task;
        [doc saveData];
        
        [_localList addObject:doc];
        
        [self sortLocalList];
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
    }
}


- (NSString *)generateFileNameWithExtension:(NSString *)extensionString {
    NSDate *time = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-hh-mm-ss"];
    NSString *timeString = [dateFormatter stringFromDate:time];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", timeString, extensionString];
    
    return fileName;
}

#pragma mark - UILocalNotification methods
-(void)setUpNotifAlarm:(ListTask *)task {
    NSDate *alertTime = task.taskDueTime;
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
                                        init];
    
    int timeDiff = (int)[task.taskDueTime timeIntervalSinceNow];
    int minDiff = timeDiff / 60;
    if (minDiff > 15) {
        [self setUpFifteenMinAheadAlarm:task];
    }
    
    if (notifyAlarm) {
        notifyAlarm.fireDate = alertTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        
        [_formatter setDateFormat:@"hh:mm a"];
        NSString *alarmTask = [NSString stringWithFormat:@"%@ - now at %@", task.taskName, [_formatter stringFromDate:task.taskDueTime]];
        notifyAlarm.alertBody = alarmTask;
        notifyAlarm.alertAction =@"view";
        notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *customInfo =[NSDictionary dictionaryWithObject:task.fileName forKey:@"fileName"];
        notifyAlarm.userInfo = customInfo;
        notifyAlarm.applicationIconBadgeNumber = 1;
        
        if (task.isCompleted == NO) {
            [app scheduleLocalNotification:notifyAlarm];
            NSLog(@"setup due notif");
        }
        else {
            [app cancelLocalNotification:notifyAlarm];
            NSLog(@"cancel due notif");
        }
    }
}

-(void)setUpRemindAlarm:(ListTask *)task {
    NSDate *alertTime = task.taskRemindTime;
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
                                        init];
    
    if (notifyAlarm) {
        notifyAlarm.fireDate = alertTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        
        [_formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];
        NSString *alarmTask = [NSString stringWithFormat:@"%@ - (due at %@)", task.taskName, [_formatter stringFromDate:task.taskDueTime]];
        notifyAlarm.alertBody = alarmTask;
        notifyAlarm.alertAction =@"view";
        notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *customInfo =[NSDictionary dictionaryWithObject:task.fileName forKey:@"fileName"];
        notifyAlarm.userInfo = customInfo;
        notifyAlarm.applicationIconBadgeNumber = 1;
        
        if (task.isCompleted == NO) {
            [app scheduleLocalNotification:notifyAlarm];
            NSLog(@"setup remind notif");
        }
        else {
            [app cancelLocalNotification:notifyAlarm];
            NSLog(@"cancel remind notif");
        }
    }
}

-(void)setUpFifteenMinAheadAlarm:(ListTask *)task {
    NSDate *alertTime = [task.taskDueTime dateByAddingTimeInterval:-15*60];
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
                                        init];

    if (notifyAlarm) {
        notifyAlarm.fireDate = alertTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        
        [_formatter setDateFormat:@"hh:mm a"];
        NSString *alarmTask = [NSString stringWithFormat:@"%@ - 15 minutes later at %@", task.taskName, [_formatter stringFromDate:task.taskDueTime]];
        notifyAlarm.alertBody = alarmTask;
        notifyAlarm.alertAction =@"view";
        notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
        NSDictionary *customInfo =[NSDictionary dictionaryWithObject:task.fileName forKey:@"fileName"];
        notifyAlarm.userInfo = customInfo;
        notifyAlarm.applicationIconBadgeNumber = 1;
        
        if (task.isCompleted == NO) {
            [app scheduleLocalNotification:notifyAlarm];
            NSLog(@"setup 15 mins notif");
        }
        else {
            [app cancelLocalNotification:notifyAlarm];
            NSLog(@"cancel 15 mins notif");
        }
    }
}

-(void)cancelScheduleAlarm:(NSString*)fileName {
    NSString *name;
    UIApplication* app = [UIApplication sharedApplication];
    NSMutableArray *Arr=[[NSMutableArray alloc] initWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
    for (int k=0;k<[Arr count];k++) {
        UILocalNotification *not=[Arr objectAtIndex:k];
        name = [not.userInfo valueForKey:@"fileName"];
        if ([name isEqualToString:fileName]) {
            [app cancelLocalNotification:not];
            NSLog(@"cancelled alarm:%@", name);
        }
    }
}

-(void)cleanAllScheduledAlarms {
    UIApplication* app = [UIApplication sharedApplication];
    NSMutableArray *Arr=[[NSMutableArray alloc] initWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
    for (int k=0;k<[Arr count];k++) {
        UILocalNotification *not=[Arr objectAtIndex:k];
        [app cancelLocalNotification:not];
    }
}

- (int)findPreRows:(NSIndexPath *)indexPath {
    int preRows;
    if (indexPath.section == 0) {
        preRows = 0;
    }
    else if (indexPath.section == 1) {
        preRows = [self numberOfTasksInThePast];
    }
    else if (indexPath.section == 2) {
        preRows = [self numberOfTasksInThePast] + [self numberOfTasksToday];
    }
    else {
        preRows = [self numberOfTasksInThePast] + [self numberOfTasksToday] + [self numberOfTasksTomorrow];
    }
    return preRows;
}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
   [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdateActivity" object:nil];
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    
    int preRows = [self findPreRows:cellIndexPath];
    
    switch (index) {
        case 0:
        {
            NSLog(@"Complete/Undo button was pressed, trying to complete/undo row %d", cellIndexPath.row + preRows);
            
            ListDoc *doc = [_localList objectAtIndex:cellIndexPath.row + preRows];

            doc.data.isCompleted = !doc.data.isCompleted;
            
            ListTask *newTask = [[ListTask alloc] init];
            newTask = doc.data;
            
            [doc deleteDoc];
            [_localList removeObjectAtIndex:cellIndexPath.row + preRows];
            
            [cell hideUtilityButtonsAnimated:YES];
            
            [self saveListItem:newTask];
            
            break;
        }
        case 1:
        {

            // Delete button was pressed
            
            NSLog(@"Delete button was pressed, trying to delete row %d", cellIndexPath.row + preRows);
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                  action:@"button_press"
                                                                   label:@"iPhone_delete_task_pressed"
                                                                   value:nil] build]];

            
            if (_iCloudIsAvailable) {
                ListDoc *doc = [_localList objectAtIndex:cellIndexPath.row + preRows];

                [[iCloud sharedCloud] deleteDocumentWithName:doc.data.fileName completion:^(NSError *error) {
                    if (!error) {
                        
                        _isUpdating = YES;
                        _updateCounter = 0;
                        
                        [self cancelScheduleAlarm:doc.data.fileName];
                        [doc deleteDoc];
                        
                        [_localList removeObjectAtIndex:cellIndexPath.row + preRows];
                               
                        [_tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
                    }
                    else {
                        NSLog(@"delete cell error");
                    }
                }];
            }
            else {
             
                ListDoc *doc = (ListDoc*)[_localList objectAtIndex:cellIndexPath.row + preRows];
                
                [self cancelScheduleAlarm:doc.data.fileName];
                
                [doc deleteDoc];
                
                [_localList removeObjectAtIndex:cellIndexPath.row + preRows];
                
                [_tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivity" object:nil];
            }
            
            break;
        }
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

@end
