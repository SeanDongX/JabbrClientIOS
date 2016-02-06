#import "CLANotificationMessage.h"

@interface CLANotificationMessage ()

// Private interface goes here.

@end

@implementation CLANotificationMessage

+ (NSString *)primaryKey {
    return @"notificationKey";
}

+ (CLANotificationMessage *)getFromData:(NSDictionary *)dataDictionary {
    CLANotificationMessage *notification = [[CLANotificationMessage alloc] init];
    notification.notificationKey = [dataDictionary objectForKey:@"notificationKey"];
    notification.fromUserName = [dataDictionary objectForKey:@"fromUserName"];
    notification.roomName = [dataDictionary objectForKey:@"roomName"];
    
    if ([dataDictionary objectForKey:@"message"] != [NSNull null]) {
        notification.message = [dataDictionary objectForKey:@"message"];
    }
    
    notification.read = [dataDictionary objectForKey:@"read"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    notification.when = [dateFormatter dateFromString:[dataDictionary objectForKey:@"when"]];
    
    return notification;
}

- (void)updateExisting:(NSDictionary *)dataDictionary {
    // Only update read
    self.read = [dataDictionary objectForKey:@"read"];
}

@end
