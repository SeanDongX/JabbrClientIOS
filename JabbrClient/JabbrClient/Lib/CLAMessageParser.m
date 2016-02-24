//
//  CLAMessageParser.m
//  Collara
//
//  Created by Sean on 23/02/16.
//  Copyright © 2016 Collara. All rights reserved.
//

#import "CLAMessageParser.h"
#import "SDWebImageManager.h"

@implementation CLAMessageParser

- (void)getMessageData:(CLAMessage *)message completionHandler:(void (^)(UIImage *))completion {
    switch ([message getType]) {
        case MessageTypeImage:
            return [self getPhotoData:message.content completionHandler:completion];
            
        case MessageTypeDocument:
            completion([self getDocumentData:message.content]);
            return;
            
        default:
            return;
    }
}

#pragma - Private Methods

- (void)getPhotoData:(NSString *)messageText completionHandler:(void (^)(UIImage *))completion {
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:messageText]
                                                    options:0
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       // progression tracking code
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      completion(image);
                                                  }];
}

- (UIImage *)getDocumentData:(NSString *)messageText {
    return [Constants documentIconLarge];
}
@end
