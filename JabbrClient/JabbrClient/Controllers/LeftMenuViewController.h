//
//  LeftMenuViewController.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuViewController
    : UIViewController <UITableViewDataSource, UISearchBarDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;

- (void)selectRoom:(NSString *)room closeMenu:(BOOL)close;

@end
