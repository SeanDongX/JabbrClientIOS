//
//  DocumentViewController.h
//  Collara
//
//  Created by Sean on 13/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "DocumentThread.h"

@interface DocumentViewController
    : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

- (void)loadDocumentThread:(DocumentThread *)documentThread;
@end
