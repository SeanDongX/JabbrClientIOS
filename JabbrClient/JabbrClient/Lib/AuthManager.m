//
//  AuthManager.m
//  JabbrClient
//
//  Created by Sean on 06/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "AuthManager.h"
#import "Constants.h"

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
        _server_url = @"http://www.collara.co/";
    }
    return self;
}

#pragma -
#pragma Public Methods

- (BOOL)isAuthenticated {
    return [self getCachedAuthToken] != nil;
}

- (NSString *)getCachedAuthToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *authDate = [defaults objectForKey:kLastAuthDate];
    
    if (!authDate){
        return nil;
    }
    else if (authDate) {
        
        NSComparisonResult result;
        result = [[NSDate date] compare:[authDate dateByAddingTimeInterval:60*60*24*7]];
        
        if (result == NSOrderedDescending){
            return nil;
        }
    }
    
    return [defaults objectForKey:kAuthToken];
}

- (NSString *)getUsername {
    return (NSString *)[self getCachedObjectForKey:kUsername];
}

#pragma -
- (void)signInWithUsername:(NSString *)username password: (NSString *)password completion:(void (^)(NSError *error))completionBlock {
    
    [self clearCookie];
    [self requestAuthTokenWithUsername:username password:password completion:^(NSString *authToken, NSError *requestError) {

        BOOL signInSuccessful = FALSE;

        if (authToken != nil) {
            [self cacheAuthToken:authToken];
            signInSuccessful = TRUE;
        }

        if (signInSuccessful) {
            [self cacheObject:username forKey:kUsername];
            if (completionBlock != nil) {
                completionBlock(nil);
            }
        } else {
            if (completionBlock != nil) {
                completionBlock(requestError);
            }
        }
    }];
}

- (void)cacheObject: (NSObject*)object forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

- (NSObject*)getCachedObjectForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

- (void)cacheAuthToken: (NSString *)authToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authToken forKey:kAuthToken];
    [defaults setObject:[NSDate date] forKey:kLastAuthDate];
    [defaults synchronize];
}


- (NSString *)fetchAuthToken:(NSData *)data {
    NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //remove "" from returned json string
    authToken = [authToken substringFromIndex:1];
    authToken = [authToken substringToIndex: [authToken length] - 1];
    return authToken;
}

- (void)clearCookie {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

- (void)requestAuthTokenWithUsername: (NSString *)username password:(NSString *)password completion:(void (^)(NSString *authToken, NSError *requestError))completionBlock{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@account/login?ReturnUrl=/account/tokenr", [AuthManager sharedInstance].server_url]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSString *postString = [NSString stringWithFormat: @"username=%@&password=%@", username, password];
    
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    [request setValue:[NSString stringWithFormat:@"%ld", [data length]] forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               if (error != nil) {
                                   completionBlock(nil, error);
                                   return;
                               }
                                   
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               NSString *actualResponseUrl = [httpResponse.URL absoluteString];
                               NSString *expectedResponseUrl = [NSString stringWithFormat: @"%@account/tokenr", self.server_url];
                               
                               NSString *authToken = nil;
                               
                               if ([actualResponseUrl rangeOfString:expectedResponseUrl options:NSCaseInsensitiveSearch].location == NSNotFound) {
                                   NSLog(@"Token request error. Expect response url '%@', but get '%@'", expectedResponseUrl, actualResponseUrl);
                               }
                               else {
                                   authToken = [self fetchAuthToken:data];
                                   NSLog(@"Authtoken acquried: %@", authToken);
                               }
                               
                               completionBlock(authToken, nil);
                           }];

}

@end
