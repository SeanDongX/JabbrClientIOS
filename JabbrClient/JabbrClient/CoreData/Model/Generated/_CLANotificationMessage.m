// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CLANotificationMessage.m instead.

#import "_CLANotificationMessage.h"

const struct CLANotificationMessageAttributes CLANotificationMessageAttributes = {
	.fromUserName = @"fromUserName",
	.message = @"message",
	.notificationKey = @"notificationKey",
	.read = @"read",
	.roomName = @"roomName",
	.when = @"when",
};

const struct CLANotificationMessageRelationships CLANotificationMessageRelationships = {
};

const struct CLANotificationMessageFetchedProperties CLANotificationMessageFetchedProperties = {
};

@implementation CLANotificationMessageID
@end

@implementation _CLANotificationMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Notification";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:moc_];
}

- (CLANotificationMessageID*)objectID {
	return (CLANotificationMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"notificationKeyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notificationKey"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"readValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"read"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic fromUserName;






@dynamic message;






@dynamic notificationKey;



- (int32_t)notificationKeyValue {
	NSNumber *result = [self notificationKey];
	return [result intValue];
}

- (void)setNotificationKeyValue:(int32_t)value_ {
	[self setNotificationKey:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveNotificationKeyValue {
	NSNumber *result = [self primitiveNotificationKey];
	return [result intValue];
}

- (void)setPrimitiveNotificationKeyValue:(int32_t)value_ {
	[self setPrimitiveNotificationKey:[NSNumber numberWithInt:value_]];
}





@dynamic read;



- (BOOL)readValue {
	NSNumber *result = [self read];
	return [result boolValue];
}

- (void)setReadValue:(BOOL)value_ {
	[self setRead:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveReadValue {
	NSNumber *result = [self primitiveRead];
	return [result boolValue];
}

- (void)setPrimitiveReadValue:(BOOL)value_ {
	[self setPrimitiveRead:[NSNumber numberWithBool:value_]];
}





@dynamic roomName;






@dynamic when;











@end
