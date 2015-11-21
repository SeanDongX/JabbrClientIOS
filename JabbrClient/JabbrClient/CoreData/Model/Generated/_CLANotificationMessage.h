// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLANotificationMessage.h instead.

#import <CoreData/CoreData.h>


extern const struct CLANotificationMessageAttributes {
    __unsafe_unretained NSString *fromUserName;
    __unsafe_unretained NSString *message;
    __unsafe_unretained NSString *notificationKey;
    __unsafe_unretained NSString *read;
    __unsafe_unretained NSString *roomName;
    __unsafe_unretained NSString *when;
} CLANotificationMessageAttributes;

extern const struct CLANotificationMessageRelationships {
} CLANotificationMessageRelationships;

extern const struct CLANotificationMessageFetchedProperties {
} CLANotificationMessageFetchedProperties;









@interface CLANotificationMessageID : NSManagedObjectID {}
@end

@interface _CLANotificationMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CLANotificationMessageID*)objectID;





@property (nonatomic, strong) NSString* fromUserName;



//- (BOOL)validateFromUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* message;



//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* notificationKey;



@property int32_t notificationKeyValue;
- (int32_t)notificationKeyValue;
- (void)setNotificationKeyValue:(int32_t)value_;

//- (BOOL)validateNotificationKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* read;



@property BOOL readValue;
- (BOOL)readValue;
- (void)setReadValue:(BOOL)value_;

//- (BOOL)validateRead:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* roomName;



//- (BOOL)validateRoomName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* when;



//- (BOOL)validateWhen:(id*)value_ error:(NSError**)error_;






@end

@interface _CLANotificationMessage (CoreDataGeneratedAccessors)

@end

@interface _CLANotificationMessage (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFromUserName;
- (void)setPrimitiveFromUserName:(NSString*)value;




- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;




- (NSNumber*)primitiveNotificationKey;
- (void)setPrimitiveNotificationKey:(NSNumber*)value;

- (int32_t)primitiveNotificationKeyValue;
- (void)setPrimitiveNotificationKeyValue:(int32_t)value_;




- (NSNumber*)primitiveRead;
- (void)setPrimitiveRead:(NSNumber*)value;

- (BOOL)primitiveReadValue;
- (void)setPrimitiveReadValue:(BOOL)value_;




- (NSString*)primitiveRoomName;
- (void)setPrimitiveRoomName:(NSString*)value;




- (NSDate*)primitiveWhen;
- (void)setPrimitiveWhen:(NSDate*)value;




@end
