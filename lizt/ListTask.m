//
//  ListItem.m
//  lizt
//
//  Created by Ziyang Tan on 3/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "ListTask.h"

@implementation ListTask

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _taskName = [aDecoder decodeObjectForKey:@"taskName"];
        _taskDueTime = [aDecoder decodeObjectForKey:@"taskDueTime"];
        _taskRemindTime = [aDecoder decodeObjectForKey:@"taskRemindTime"];
        _taskNotes = [aDecoder decodeObjectForKey:@"taskNotes"];
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _isCompleted = [aDecoder decodeBoolForKey:@"isCompleted"];
        _lastModifiedDate = [aDecoder decodeObjectForKey:@"lastModifiedDate"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_taskName forKey:@"taskName"];
    [aCoder encodeObject:_taskDueTime forKey:@"taskDueTime"];
    [aCoder encodeObject:_taskRemindTime forKey:@"taskRemindTime"];
    [aCoder encodeObject:_taskNotes forKey:@"taskNotes"];
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeBool:_isCompleted forKey:@"isCompleted"];
    [aCoder encodeObject:_lastModifiedDate forKey:@"lastModifiedDate"];
}

@end
