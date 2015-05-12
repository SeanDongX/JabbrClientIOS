//
//  CLACreateTeamViewController.h
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>

//Message Client
#import "CLASignalRMessageClient.h"

//View Controllers
#import "SlidingViewController.h"

@interface CLACreateTeamViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) SlidingViewController *slidingMenuViewController;

@end
