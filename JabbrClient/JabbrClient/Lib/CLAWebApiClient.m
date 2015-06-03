//
//  CLAWebApiClient.m
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAWebApiClient.h"
#import "AuthManager.h"
#import "AFNetworking.h"
#import "Constants.h"

@interface CLAWebApiClient()

@property (strong, nonatomic) AFHTTPRequestOperationManager* connectionManager;

@end

@implementation CLAWebApiClient

#pragma mark -
#pragma mark Singleton

static CLAWebApiClient *SINGLETON = nil;
static bool isFirstAccess = YES;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[CLAWebApiClient alloc] init];
}

- (id)mutableCopy
{
    return [[CLAWebApiClient alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    self.connectionManager =  [AFHTTPRequestOperationManager manager];
    self.connectionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}


#pragma mark -
#pragma mark CLAApiCleint Methods

- (void)createAccount:(CLAUserRegistrationViewModel *)userRegistrationModel completionHandler:(void (^)(NSString *errorMessage))completion {
    
    
    
    NSArray *array = @[kServerBaseUrl, kApiPath, @"accounts/signup"];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    NSDictionary *params = @ {
        @"Username" : userRegistrationModel.username,
        @"Name" : userRegistrationModel.name,
        @"Email" : userRegistrationModel.email,
        @"Password" : userRegistrationModel.password,
        @"ConfirmPassword" : userRegistrationModel.confirmPassword,
    };
    
    
    [self.connectionManager POST:requestUrl parameters:params
                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                             NSString *token = [responseObject objectForKey:@"token"];
                             NSString *message = nil;
                             if (token == nil || token.length == 0) {
                                 message = NSLocalizedString(@"We are terribly sorry, but some error happened.", nil);
                             }
                             else {
                                 [[AuthManager sharedInstance] cacheAuthToken:token];
                                 [[AuthManager sharedInstance] cacheUsername:userRegistrationModel.username];
                             }
                             
                             completion(message);

     }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             completion([self getResponseErrorMessage:error]);
     }];
}

- (void)signInWith: (NSString *)username password:(NSString *)password completionHandler:(void (^)(NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath, @"accounts/signin"];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    NSDictionary *params = @ {
        @"Username" : username,
        @"Password" : password,
    };
    
    [self.connectionManager POST:requestUrl parameters:params
                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
     {
         NSString *token = [responseObject objectForKey:@"token"];
         NSString *message = nil;
         if (token == nil || token.length == 0) {
             message = NSLocalizedString(@"We are terribly sorry, but we can not sign you in now.", nil);
         }
         else {
             [[AuthManager sharedInstance] cacheAuthToken:token];
             [[AuthManager sharedInstance] cacheUsername:username];
             NSLog(@"Received and cached username %@ and token %@", username, token);
         }
         
         completion(message);
     }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         completion([self getResponseErrorMessage:error]);
     }];
}


- (void)createTeam:(NSString *)name completionHandler: (void(^)(NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath, @"accounts/team/", name, @"?token=", [self getToken]];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    [self.connectionManager POST:requestUrl parameters:nil
                         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(nil);
     }
                         failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         completion([self getResponseErrorMessage:error]);
     }];
}

- (void)joinTeam:(NSString *)invitationCode completionHandler: (void(^)(NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath,  @"accounts/team/join/", invitationCode, @"/?token=", [self getToken]];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    [self.connectionManager POST:requestUrl parameters:nil
                         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(nil);
     }
                         failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         completion([self getResponseErrorMessage:error]);
     }];
}

- (void)getInviteCodeForTeam:(NSNumber *)teamKey completion:(void(^)(NSString *invitationCode, NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath,  @"accounts/team/", teamKey, @"/invite/?token=", [self getToken]];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    [self.connectionManager GET:requestUrl parameters:nil
                         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion([responseObject objectForKey:@"id"], nil);
     }
                         failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         completion(nil, [self getResponseErrorMessage:error]);
     }];
}

- (void)sendInviteFor:(NSNumber *)team to:(NSString *)email completion:(void(^)(NSString *token, NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath,  @"accounts/team/", team, @"/sendinvite/", email, @"/?token=", [self getToken]];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    [self.connectionManager POST:requestUrl parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject, nil);
     }
    failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         completion(nil, [self getResponseErrorMessage:error]);
     }];
}
                                                                                                                       
- (NSString *)getToken {
    return [[AuthManager sharedInstance] getCachedAuthToken];
}

- (NSString *)getResponseErrorMessage: (NSError *)error {
    NSError *localError = nil;
    NSString *errorMessage = nil;
    
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    
    if (errorData != nil) {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:errorData options:0 error:&localError];
    
       errorMessage = [parsedObject valueForKey:@"message"];
    }
    
    if (errorMessage == nil || errorMessage.length == 0) {
        errorMessage =  NSLocalizedString(@"We are terribly sorry, but some error happened.", nil);
    }
    
    return errorMessage;
}

@end
