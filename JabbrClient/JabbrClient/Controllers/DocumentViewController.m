//
//  DocumentViewController.m
//  JabbrClient
//
//  Created by Sean on 31/03/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "DocumentViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "Constants.h"
#import "DocumentThread+Category.h"

@interface DocumentViewController()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftMenuButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightMenuButton;

@property (nonatomic, strong) DocumentThread* currentDocumentThread;

@end

@implementation DocumentViewController{
    IBOutlet __weak UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMenu];
    [self initProgressDelegate];
    [self loadDocumentThread:self.currentDocumentThread];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //TODO: Bug - progress bar not shown, mostly like conflict with ECSlidingViewontroller
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Menu Setup

- (void)initMenu {
    
    [self.leftMenuButton setTitle:@""];
    [self.leftMenuButton setWidth:30];
    [self.leftMenuButton setImage: [Constants menuIconImage]];
    
    
    [self.rightMenuButton setTitle:@""];
    [self.rightMenuButton setWidth:30];
    [self.rightMenuButton setImage: [Constants docIconImage]];
}


#pragma mark -
#pragma mark - Navigation

- (IBAction)leftMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (IBAction)rightMenuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToLeftAnimated:YES];
}


#pragma -
#pragma WebView Progress Indicator

- (void)initProgressDelegate {
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView.progressBarView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)loadDocumentThread:(DocumentThread *)documentThread {

    if (documentThread)
    {
        self.currentDocumentThread = documentThread;
        self.navigationItem.title = [self.currentDocumentThread getDisplayTitle];
        
        if (self.currentDocumentThread.url)
        {
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL: self.currentDocumentThread.url];
            [_webView loadRequest:req];
        }
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

@end
