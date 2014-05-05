//
//  AppDelegate.m
//  lizt
//
//  Created by Ziyang Tan on 2/22/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConfig.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]}];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHex:0x5AC8FB]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor colorWithHex:0x5AC8FB]]];
    
#if !DEBUG
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-49736286-1"];
#endif

    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
	// Handle the notificaton when the app is running
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notif.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateList" object:nil];
    }
    
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self arrangeBadgeNumbers];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"will enter foreground");
    application.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkAvailability" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"will terminate");
    [self arrangeBadgeNumbers];
}

-(void)arrangeBadgeNumbers{
    _notificationsArray = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
    NSLog(@"notifications array count: %d",_notificationsArray.count);
    NSMutableArray *fireDates = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i< _notificationsArray.count; i++)
    {
        UILocalNotification *notif = [self.notificationsArray objectAtIndex:i];
        NSDate *firedate = notif.fireDate;
        [fireDates addObject:firedate];
    }
    NSArray *sortedFireDates= [fireDates sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSInteger i=0; i< _notificationsArray.count; i++)
    {
        UILocalNotification *notif = [_notificationsArray objectAtIndex:i];
        notif.applicationIconBadgeNumber=[sortedFireDates indexOfObject:notif.fireDate]+1;
    }
    [[UIApplication sharedApplication] setScheduledLocalNotifications:_notificationsArray];
    
    _notificationsArray = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
    
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];

    for (int i  = 0; i < _notificationsArray.count; i++) {
        UILocalNotification *notif = [self.notificationsArray objectAtIndex:i];
        NSLog(@"appdelegate fireName %@, fileDate %@", [notif.userInfo valueForKey:@"fileName"], [formatter stringFromDate:notif.fireDate]);
    }
}


@end
