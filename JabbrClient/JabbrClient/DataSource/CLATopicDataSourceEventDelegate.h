//
//  CLATopicDataSourceEventDelegate.h
//  Collara
//
//  Created by Sean on 21/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLATopicDataSourceEventDelegate <NSObject>

- (void)showCreateTopicView:(id)sender;
- (void)sectionToggled:(NSInteger)section toOpen:(BOOL)open;

@end