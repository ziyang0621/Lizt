//
//  UIImage+Extras.m
//  lizt
//
//  Created by Ziyang Tan on 5/1/14.
//  Copyright (c) 2014 ziyang. All rights reserved.
//

#import "UIImage+Extras.h"

@implementation UIImage (Extras)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
