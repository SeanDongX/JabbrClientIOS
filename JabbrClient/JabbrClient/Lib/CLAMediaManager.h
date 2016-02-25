//
//  CLAMediaManager.h
//  Collara
//
//  Created by Sean on 08/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAMessage.h"

@interface CLAMediaManager : NSObject


+ (BOOL) presentPhotoCamera:(id)target canEdit:(BOOL)canEdit;
+ (BOOL) presentPhotoLibrary:(id)target canEdit:(BOOL)canEdit;

+ (void)showImage:(CLAMessage*)message from:(id)target;
@end
