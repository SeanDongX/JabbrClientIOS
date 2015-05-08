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
    NSArray *array = @[kServerBaseUrl, kApiPath, @"accounts"];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    NSDictionary *params = @ {
        @"Username" : userRegistrationModel.username,
        @"Email" : userRegistrationModel.email,
        @"Password" : userRegistrationModel.password,
        @"ConfirmPassword" : userRegistrationModel.confirmPassword,
    };
    
    [self.connectionManager POST:requestUrl parameters:params
                         success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
     {
         NSString *token = [responseObject objectForKey:@"token"];
         NSString *message = nil;
         
         if (token == nil || token.length == 0) {
             message = @"We are terribly sorry, but some error happened.";
         }
         else {
             [[AuthManager sharedInstance] cacheAuthToken:token];
             [[AuthManager sharedInstance] cacheUsername:userRegistrationModel.username];
         }
         
         completion(message);
     }
                         failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)joinTeam:(NSString *)name completionHandler: (void(^)(NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath,  @"accounts/team/join/", name, [self getToken]];
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
                                                                                                       
- (void)sendInviteFor:(NSString*)team to:(NSString *)email completion: (void(^)(NSString *token, NSString *errorMessage))completion {
    NSArray *array = @[kServerBaseUrl, kApiPath,  @"accounts/team/", team, @"/sendinvite/", email, @"/?token=", [self getToken]];
    NSString *requestUrl = [array componentsJoinedByString:@""];
    
    [self.connectionManager POST:requestUrl parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         completion(responseObject, nil);
         NSLog(@"JSON: %@", responseObject);
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
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:&localError];
    
    NSString *errorMessage = [parsedObject valueForKey:@"message"];
    
    if (errorMessage == nil || errorMessage.length == 0) {
        errorMessage = @"We are terribly sorry, but some error happened.";
    }
    
    return errorMessage;
}

@end
