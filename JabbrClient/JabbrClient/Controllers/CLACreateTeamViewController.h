//
//  CLACreateTeamViewController.h
//  Collara
//
//  Created by Sean on 05/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLASignalRMessageClient.h"

@interface CLACreateTeamViewController : UIViewController

@property (strong, nonatomic) id<CLAMessageClient> messagClient;

@end
