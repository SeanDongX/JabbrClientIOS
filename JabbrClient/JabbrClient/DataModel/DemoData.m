//
//  DemoData.m
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "DemoData.h"
#import "DocumentThread.h"
#import <JSQMessagesViewController/JSQMessages.h>

@implementation DemoData

+ (DemoData *)sharedDemoData {
    static DemoData *sharedDemoData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDemoData = [[self alloc] init];
    });
    return sharedDemoData;
}

- (id)init {
    if (self = [super init]) {
        [self setupUsernamePassword];
        [self setupDocumentThreads];
    }
    return self;
}

- (void)setupUsernamePassword {
    self.myUsername = @"Mike";
    self.mySenderId = @"Mike";
    self.myPassword = @"Password1";
}

- (void)setupDocumentThreads {
    self.documentThreads = [NSMutableArray array];
    
    DocumentThread *pitchSpeech = [[DocumentThread alloc] init];
    pitchSpeech.name = @"PitchBrainstorm";
    pitchSpeech.url = [NSURL
                       URLWithString:[NSString stringWithFormat:@"http://doc.collara.co/p/"
                                      @"878XT1YtTH?showChat=false&"
                                      @"userName=%@",
                                      self.myUsername]];
    
    DocumentThread *featureDocument = [[DocumentThread alloc] init];
    featureDocument.name = @"FeatureDocument";
    featureDocument.url = [NSURL
                           URLWithString:[NSString stringWithFormat:@"http://doc.collara.co/p/"
                                          @"DpfVMMrnEx?showChat=false&"
                                          @"userName=%@",
                                          self.myUsername]];
    
    [self.documentThreads addObject:pitchSpeech];
    [self.documentThreads addObject:featureDocument];
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
