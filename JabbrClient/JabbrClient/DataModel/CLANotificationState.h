//
//  CLANotificationState.h
//  Collara
//
//  Created by Sean on 07/01/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLANotificationState : NSObject

@property(nonatomic, strong) NSString *TeamName;
@property(nonatomic, strong) NSString *RoomName;
@property(nonatomic) bool isSnoozeOn;
@property(nonatomic, strong) NSDate *snoozeUntil;

@end
