//
//  TrackDoc.h
//  lizt
//
//  Created by Ziyang Tan on 5/3/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackData.h"

@interface TrackDoc : NSObject

@property (nonatomic) TrackData *data;
@property (copy) NSString *docPath;

- (id)initWithDocPath:(NSString *)docPath;
- (void)saveData;
- (void)deleteDoc;

@end
