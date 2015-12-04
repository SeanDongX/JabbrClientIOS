//
//  CLAMessageFactory.m
//  Collara
//
//  Created by Sean on 02/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import "CLAMessageFactory.h"

@implementation CLAMessageFactory

#pragma mark -
#pragma mark - Public Methods

- (CLAMessage *)create:(NSDictionary *)messageDictionary {
    NSString *userName = @"?";
    NSString *userInitials = @"?";
    
    NSDictionary *userData = [messageDictionary objectForKey:@"User"];
    
    NSString *dateString = [messageDictionary objectForKey:@"When"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    
    if (userData) {
        if ([userData objectForKey:@"Name"]) {
            userName = [[userData objectForKey:@"Name"] lowercaseString];
            userInitials = userName;
        }
        
        if ([userData objectForKey:@"Initials"]) {
            userInitials = [userData objectForKey:@"Initials"];
        }
    }
    
    NSString *oId = [messageDictionary objectForKey:@"Id"];
    NSString *text = [messageDictionary objectForKey:@"Content"];
    
    return [[CLAMessage alloc]
            initWithOId:oId
            SenderId:userName
            senderDisplayName:userInitials
            date:date
            text:text];
}

@end
