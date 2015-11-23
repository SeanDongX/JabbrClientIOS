//
//  CLACreateTopicViewController
//  Collara
//
//  Created by Sean on 22/11/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLForm.h"
#import "XLFormViewController.h"
#import "Constants.h"

@interface CLACreateTopicViewController : XLFormViewController <UITextFieldDelegate>

@property RoomType roomType;

- (instancetype)initWithRoomType:(RoomType)roomType;

@end
