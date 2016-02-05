//
//  UIColor+HexString.h
//  Collara
//
//  Created by Sean on 05/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end