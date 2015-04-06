//
//  AuthManager.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "AuthManager.h"

@implementation AuthManager


+ (AuthManager *)sharedInstance {
    static AuthManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _server_url = @"http://collara.co/";
        _isAuthenticated = FALSE;
    }
    return self;
}

- (void)signInWithUsername:(NSString *)username password: (NSString *)password completion:(void (^)(NSError *error))completionBlock {
    
    BOOL signInSuccessful = FALSE;
    
    signInSuccessful = TRUE;
    
    if (signInSuccessful) {
        if (completionBlock != nil) completionBlock(nil);
    } else {
        NSInteger errorCode = 0;
        NSError *error = [NSError errorWithDomain:@"SignIn" code:errorCode userInfo:nil];
        if (completionBlock != nil) completionBlock(error);
    }
}

@end
