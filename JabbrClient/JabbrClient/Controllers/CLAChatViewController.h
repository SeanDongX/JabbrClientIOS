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
#import "UIScrollView+EmptyDataSet.h"

@interface CLAChatViewController : SLKTextViewController <CLAMessageClientDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

- (void)setActiveRoom:(CLARoom *)room;

- (void)showTaskView;
- (void)showInfoView;
@end
