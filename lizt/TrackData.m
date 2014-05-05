//
//  TrackData.m
//  lizt
//
//  Created by Ziyang Tan on 5/3/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "TrackData.h"

@implementation TrackData


-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _completeChart = [aDecoder decodeObjectForKey:@"completeChart"];
        _lastModifiedDate = [aDecoder decodeObjectForKey:@"lastModifiedDate"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_completeChart forKey:@"completeChart"];
    [aCoder encodeObject:_lastModifiedDate forKey:@"lastModifiedDate"];
}

@end
