#import "CLANotificationMessage.h"

@interface CLANotificationMessage ()

// Private interface goes here.

@end

@implementation CLANotificationMessage

+ (NSString *)primaryKey {
    return @"notificationKey";
}

+ (NSArray <CLANotificationMessage *> *)getFromDataArray:(NSArray *)dictionaryArray {
    NSMutableArray <CLANotificationMessage *> *notifications = [NSMutableArray array];
    if (dictionaryArray && dictionaryArray != [NSNull null] && dictionaryArray.count > 0) {
        for (NSDictionary *dictionary in dictionaryArray) {
            CLANotificationMessage *notification = [CLANotificationMessage getFromData:dictionary];
            if (notification) {
                [notifications addObject:notification];
            }
        }
    }
    return notifications;
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
