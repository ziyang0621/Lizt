//
//  ListItem.h
//  lizt
//
//  Created by Ziyang Tan on 3/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ListTask : NSObject <NSCoding>

@property (strong, nonatomic)NSString *taskName;
@property (strong, nonatomic)NSDate *taskDueTime;
@property (strong, nonatomic)NSDate *taskRemindTime;
@property (strong, nonatomic)NSData *taskNotes;
@property (strong, nonatomic)NSString *fileName;
@property (strong, nonatomic)NSDate *lastModifiedDate;
@property (nonatomic)BOOL isCompleted;

@end
