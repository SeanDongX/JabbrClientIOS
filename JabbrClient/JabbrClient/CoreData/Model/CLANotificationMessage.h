#import "_CLANotificationMessage.h"

@interface CLANotificationMessage : _CLANotificationMessage {
}

- (void)parseData:(NSDictionary *)dataDictionary;
- (void)updateExisting:(NSDictionary *)dataDictionary;

@end
