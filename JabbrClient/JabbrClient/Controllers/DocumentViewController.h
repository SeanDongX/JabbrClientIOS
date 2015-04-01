//
//  DocumentViewController.h
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "DocumentThread.h"

@interface DocumentViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

- (void)loadDocumentThread:(DocumentThread *)documentThread;
@end
