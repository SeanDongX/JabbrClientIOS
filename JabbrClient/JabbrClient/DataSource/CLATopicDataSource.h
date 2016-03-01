//
//  CLATopicDataSource.h
//  Collara
//
//  Created by Sean on 20/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLARoom.h"
#import "SlidingViewController.h"
#import "CLATopicDataSourceEventDelegate.h"

@interface CLATopicDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<CLATopicDataSourceEventDelegate> eventDelegate;

@property (nonatomic) BOOL isFiltered;
@property (nonatomic, strong) CLARoom *selectedRoom;
@property (nonatomic, strong) SlidingViewController *slidingViewController;

@property (nonatomic, strong) NSString *tableCellIdentifierName;

@property (nonatomic) BOOL advancedMode;
@property (nonatomic, strong) UIColor *sectionHeaderBackgronndColor;
@property (nonatomic, strong) UIColor *sectionHeaderTextColor;
@property (nonatomic, strong) UIColor *rowTextColor;
@property (nonatomic, strong) UIColor *rowBackgroundColor;
@property (nonatomic, strong) UIColor *rowSelectedBackgroundColor;

- (NSIndexPath *)getSelectedRoomIndexPath;

- (void)updateRooms:(NSArray<CLARoom *> *)rooms;
- (void)openRoom: (CLARoom *)room;
- (void)resetFilter;
- (void)filterContentForSearchText:(NSString *)searchText;

@end
