//
//  ListDoc.h
//  lizt
//
//  Created by Ziyang Tan on 3/19/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListTask.h"

@interface ListDoc : NSObject

@property (nonatomic) ListTask *data;
@property (copy) NSString *docPath;

- (id)initWithDocPath:(NSString *)docPath;
- (void)saveData;
- (void)deleteDoc;

@end
