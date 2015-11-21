//
//  RightMenuViewController.h
//  Collara
//
//  Created by Sean on 29/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightMenuViewController : UIViewController <UITableViewDataSource>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@end
