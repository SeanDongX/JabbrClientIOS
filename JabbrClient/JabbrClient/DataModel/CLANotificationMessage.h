//
//  CLANotificationMessage.h
//  Collara
//
//  Created by Sean on 06/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface CLANotificationMessage : RLMObject

@property (nonatomic, strong) NSString* fromUserName;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSNumber<RLMInt>* notificationKey;
@property (nonatomic) BOOL read;
@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) NSDate* when;


+ (CLANotificationMessage *)getFromData:(NSDictionary *)dataDictionary;
+ (NSArray <CLANotificationMessage *> *)getFromDataArray:(NSArray *)dictionaryArray;
- (void)updateExisting:(NSDictionary *)dataDictionary;

@end

RLM_ARRAY_TYPE(CLANotificationMessage)