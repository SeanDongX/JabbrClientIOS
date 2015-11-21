//
//  CLANotifictionTableViewCell.h
//  Collara
//
//  Created by Sean on 04/07/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLANotificationMessage.h"

@interface CLANotifictionTableViewCell : UITableViewCell

@property(strong, nonatomic) CLANotificationMessage *notification;

@end
