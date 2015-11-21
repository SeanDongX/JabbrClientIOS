//
//  CLAInviteTopicInfoViewController.h
//  Collara
//
//  Created by Sean on 24/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"
#import "XLFormViewController.h"

// Data Models
#import "CLARoomViewModel.h"

@interface CLATopicInfoViewController
: XLFormViewController <UITextFieldDelegate>

- (instancetype)initWithRoom:(CLARoomViewModel *)roomViewModel;

@end
