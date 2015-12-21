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

@interface CLATopicDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL isFiltered;
@property(nonatomic, strong) CLARoom *selectedRoom;
@property (nonatomic, strong) SlidingViewController *slidingViewController;

- (NSIndexPath *)getSelectedRoomIndexPath;

- (void)updateRooms:(NSArray<CLARoom *> *)rooms;
- (void)openRoom: (CLARoom *)room;
- (void)resetFilter;
- (void)filterContentForSearchText:(NSString *)searchText;
- (void)highlightCurrentSelection;
@end
