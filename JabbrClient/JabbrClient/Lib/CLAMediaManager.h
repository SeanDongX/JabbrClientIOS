//
//  CLAMediaManager.h
//  Collara
//
//  Created by Sean on 08/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAMediaManager : NSObject


+ (BOOL) presentPhotoCamera:(UIViewController *)target canEdit:(BOOL)canEdit;
+ (BOOL) presentPhotoLibrary:(UIViewController *)target canEdit:(BOOL)canEdit;

@end
