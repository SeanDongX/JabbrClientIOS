//
//  CLAInviteTopicInfoViewController.h
//  Collara
//
//  Created by Sean on 24/06/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"
#import "CLARoom.h"

@interface CLATopicInfoViewController : XLFormViewController <UITextFieldDelegate>

- (instancetype)initWithRoomKey:(NSNumber *)roomKey;

@end
