//
//  CLATaskWebViewController.m
//  Collara
//
//  Created by Sean on 18/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLATaskWebViewController.h"
#import "Constants.h"
#import "UserDataManager.h"

@interface CLATaskWebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) BOOL authorized;

@end

@implementation CLATaskWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    [self initWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.authorized != YES) {
        [self loadAuthFrame];
    } else {
        [self loadBoard];
    }
}

- (void)setupNavBar {
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)initWebView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.webView = [[UIWebView alloc] initWithFrame:
                    CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [self.view addSubview:self.webView];
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.authorized != YES) {
        self.authorized = YES;
        [self loadBoard];
    }
    //[self logLocalStorage];
}

- (void)loadBoard {
    NSURL *boardUrl = [self getBoardUrl];
    if (![self.webView.request.URL.absoluteString isEqualToString: boardUrl.absoluteString]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL: boardUrl]];
    }
}

- (void)loadAuthFrame {
    NSURL *authUrl = [NSURL URLWithString:[UserDataManager getTaskAuthFrameUrl]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authUrl]];
}

- (NSURL *)getBoardUrl {
    NSArray *array = @[kTaskServiceRootUrl, @"redirect/b/", [UserDataManager getTeam].name, @"/", self.roomName];
    //Task board needs lower case url for board name
    
    return [NSURL URLWithString:[array componentsJoinedByString:@""].lowercaseString];
}

- (void)logLocalStorage {
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:@"localStorage.getItem('Meteor.loginToken')"];
    NSLog(@"------- %@ -------", result);
}
@end
