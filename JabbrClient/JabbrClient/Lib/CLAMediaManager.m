//
//  CLAMediaManager.m
//  Collara
//
//  Created by Sean on 08/12/15.
//  Copyright © 2015 Collara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CLAMediaManager.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import "Constants.h"
#import "CLAMessageParser.h"
//#import "JSQPhotoMediaItem.h"
//#import "CLADisplayMessageFactory.h"


@implementation CLAMediaManager

+ (BOOL) presentPhotoCamera:(id)target canEdit:(BOOL)canEdit {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    NSString *type = (NSString *)kUTTypeImage;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type]) {
        imagePicker.mediaTypes = @[type];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else {
        return NO;
    }
    
    imagePicker.allowsEditing = canEdit;
    imagePicker.showsCameraControls = YES;
    imagePicker.delegate = target;
    [target presentViewController:imagePicker animated:YES completion:nil];
    return YES;
}

+ (BOOL) presentPhotoLibrary:(id)target canEdit:(BOOL)canEdit {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        
        return NO;
    }
    
    NSString *type = (NSString *)kUTTypeImage;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else {
        return NO;
    }
    
    imagePicker.allowsEditing = canEdit;
    imagePicker.delegate = target;
    [target presentViewController:imagePicker animated:YES completion:nil];
    
    return YES;
}

+ (void)showImage:(CLAMessage*)message from:(id)target {
    CLAMessageParser *messageParser = [[CLAMessageParser alloc] init];
    [messageParser getMessageData: message completionHandler:^(UIImage *image) {
        if (!image) {
            return;
        }
        
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = image;
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        [imageViewer showFromViewController:target transition:JTSImageViewControllerTransition_FromOriginalPosition];
        
    }];
}

+ (void)openDocument:(NSString *)mediaUrl {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mediaUrl]];
}
@end
