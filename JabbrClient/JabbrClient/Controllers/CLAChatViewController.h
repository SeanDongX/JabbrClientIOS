//
//  CLAChatViewController.h
//  Collara
//
//  Created by Sean on 10/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLAMessageClient.h"
#import "SLKTextViewController.h"

@interface CLAChatViewController : SLKTextViewController <CLAMessageClientDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

- (void)setActiveRoom:(CLARoom *)room;

- (void)showTaskView;
- (void)showInfoView;
@end
