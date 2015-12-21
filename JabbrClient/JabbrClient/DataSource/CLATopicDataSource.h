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
#import "BOZPongRefreshControl.h"

@interface CLATopicDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL isFiltered;
@property (nonatomic, strong) CLARoom *selectedRoom;
@property (nonatomic, strong) SlidingViewController *slidingViewController;
@property (nonatomic, strong) BOZPongRefreshControl *pongRefreshControl;

@property (nonatomic, strong) NSString *tableCellIdentifierName;

- (NSIndexPath *)getSelectedRoomIndexPath;

- (void)updateRooms:(NSArray<CLARoom *> *)rooms;
- (void)openRoom: (CLARoom *)room;
- (void)resetFilter;
- (void)filterContentForSearchText:(NSString *)searchText;
- (void)highlightCurrentSelection;
@end
