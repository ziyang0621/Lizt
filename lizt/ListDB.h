//
//  ListDB.h
//  lizt
//
//  Created by Ziyang Tan on 3/19/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListDB : NSObject

+ (NSMutableArray *)loadDocs;
+ (NSString *)nextDocPath;

@end
