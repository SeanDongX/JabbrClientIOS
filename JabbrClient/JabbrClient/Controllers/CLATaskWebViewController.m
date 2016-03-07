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
#import "CLANotificationManager.h"

@interface CLATaskWebViewController ()

@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) BOOL authorized;

@end

@implementation CLATaskWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [CLANotificationManager showText: NSLocalizedString(@"Loading...", nil)
                   forViewController:self
                            withType:CLANotificationTypeMessage];
    
    
    if (self.authorized != YES) {
        [self loadAuthFrame];
    } else {
        [self loadBoard];
    }
}

- (void)switchRoom:(NSString *)roomName {
    self.roomName = roomName;
}

- (void)setupView {
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [Constants mainThemeContrastColor];
}

- (void)initWebView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.webView = [[UIWebView alloc] initWithFrame:
                    CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    self.webView.backgroundColor = [Constants mainThemeContrastColor];
    
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
    NSString *urlString = [array componentsJoinedByString:@""];
    
    //Hanlder chinese chars in url
    urlString = [urlString.lowercaseString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:urlString];
}

@end
