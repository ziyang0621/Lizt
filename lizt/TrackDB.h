//
//  TrackDB.h
//  lizt
//
//  Created by Ziyang Tan on 5/3/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackDB : NSObject

+ (NSMutableArray *)loadDocs;
+ (NSString *)nextDocPath;

@end
