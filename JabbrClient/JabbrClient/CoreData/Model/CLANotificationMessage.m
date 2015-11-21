#import "CLANotificationMessage.h"

@interface CLANotificationMessage ()

// Private interface goes here.

@end

@implementation CLANotificationMessage

- (void)parseData:(NSDictionary *)dataDictionary {
  self.notificationKey = [dataDictionary objectForKey:@"notificationKey"];
  self.fromUserName = [dataDictionary objectForKey:@"fromUserName"];
  self.roomName = [dataDictionary objectForKey:@"roomName"];
  self.message = [dataDictionary objectForKey:@"message"];
  self.read = [dataDictionary objectForKey:@"read"];

  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
  self.when = [dateFormat dateFromString:[dataDictionary objectForKey:@"when"]];
}

- (void)updateExisting:(NSDictionary *)dataDictionary {
  // Only update read
  self.read = [dataDictionary objectForKey:@"read"];
}
@end
