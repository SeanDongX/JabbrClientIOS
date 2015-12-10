//
//  CLAUtility.m
//  Collara
//
//  Created by Sean on 08/05/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAUtility.h"


#import "Constants.h"
#import "AuthManager.h"

@implementation CLAUtility

+ (BOOL)isValidEmail:(NSString *)email {
    BOOL stricterFilter = NO; // Discussion
    // http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString =
    @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isString:(NSString *)firstString
caseInsensitiveEqualTo:(NSString *)secondString {
    return firstString &&
    [firstString caseInsensitiveCompare:secondString] == NSOrderedSame;
}

+ (id)getUserDefault:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)setUserDefault:(id)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+ (NSString *)getUrlString:(UIImage *)image {
    return [NSString stringWithFormat:@"data:%@;base64,%@",
            kMimeTypeJpeg,
            [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

+ (NSDictionary *)getImagePostData:(UIImage *)image imageName:(NSString *)imageName fromRoom:(NSString *)roomName {
    NSDictionary *dictionary = @{ kFileUploadFile : [CLAUtility getUrlString:image],
                                  kFileUploadFileName : imageName,
                                  kFileUploadType : kMimeTypeJpeg,
                                  kTeamKey : [CLAUtility getUserDefault:kTeamKey],
                                  kFileUploadRoom: roomName};
    
    return dictionary;
}
@end
