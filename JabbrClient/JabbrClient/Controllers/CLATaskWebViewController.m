//
//  CLATaskWebViewController.m
//  Collara
//
//  Created by Sean on 18/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLATaskWebViewController.h"
#import "Constants.h"
#import "AuthManager.h"

@interface CLATaskWebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) BOOL authorized;

@end

@implementation CLATaskWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWebView];
}

- (void)initWebView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.webView = [[UIWebView alloc] initWithFrame:
                    CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [self.view addSubview:self.webView];
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    
    if (self.authorized != YES) {
        [self loadAuthFrame];
    } else {
        [self loadBoard];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.authorized != YES) {
        self.authorized = YES;
        [self loadBoard];
    }
    
    //[self logLocalStorage];
}

- (void)loadBoard {
    [self.webView loadRequest:[self getBoardRequest]];
}

- (void)loadAuthFrame {
    NSURL *authUrl = [NSURL URLWithString:[[AuthManager sharedInstance] getTaskAuthFrameUrl]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authUrl]];
}

- (NSURLRequest *)getBoardRequest {
    //TODO: team name
    NSArray *array = @[kTaskServiceRootUrl, @"redirect/b/", @"awesome", @"/", self.roomName];
    //Task board needs lower case url for board name
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[array componentsJoinedByString:@""].lowercaseString]];
}

- (void)logLocalStorage {
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:@"localStorage.getItem('Meteor.loginToken')"];
    NSLog(@"------- %@ -------", result);
}
@end
