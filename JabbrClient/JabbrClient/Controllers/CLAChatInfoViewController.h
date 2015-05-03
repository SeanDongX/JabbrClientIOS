//
//  CLAChatInfoViewController.h
//  Collara
//
//  Created by Sean on 02/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLARoomViewModel.h"

@interface CLAChatInfoViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) CLARoomViewModel *roomViewModel;

@end