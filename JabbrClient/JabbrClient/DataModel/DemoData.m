//
//  DemoData.m
//  JabbrClient
//
//  Created by Sean on 01/04/15.
//  Copyright (c) 2015 Colla. All rights reserved.
//

#import "DemoData.h"
#import "DocumentThread.h"
#import "ChatThread.h"
#import <JSQMessagesViewController/JSQMessages.h>

static NSString * const kMe = @"mike";
static NSString * const kJenifer = @"jenifer";
static NSString * const kKate = @"kate";

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
        [self setupAvatars];
        [self setupDocumentThreads];
        [self setupChatThreads];
    }
    return self;
}

- (void)setupUsernamePassword {
    self.myUsername = @"Mike";
    self.mySenderId = @"Mike";
    self.myPassword = @"Password1";
}


- (void)setupAvatars {
    
    JSQMessagesAvatarImage *avatorUser1 = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"Avator_User1"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    JSQMessagesAvatarImage *avatorUser2 = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"Avator_User2"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    JSQMessagesAvatarImage *avatorUser3 = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"Avator_User3"] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    self.avatars = @{ kMe : avatorUser2,
                      kJenifer : avatorUser1,
                      kKate: avatorUser3 };
}

- (void)setupDocumentThreads {
    self.documentThreads = [NSMutableArray array];
    
    DocumentThread *pitchSpeech = [[DocumentThread alloc] init];
    pitchSpeech.title = @">PitchBrainstorm";
    pitchSpeech.url = [NSURL URLWithString: [NSString stringWithFormat:@"http://colladox.cloudapp.net/p/878XT1YtTH?showChat=false&userName=%@", self.myUsername]];
    
    DocumentThread *featureDocument = [[DocumentThread alloc] init];
    featureDocument.title = @"FeatureDocument";
    featureDocument.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://colladox.cloudapp.net/p/DpfVMMrnEx?showChat=false&userName=%@", self.myUsername]];
    
    
    [self.documentThreads addObject:pitchSpeech];
    [self.documentThreads addObject:featureDocument];
}


- (void)setupChatThreads {
    
    self.chatThreads = [NSMutableArray array];
    
    ChatThread *pitchSpeech = [[ChatThread alloc] init];
    pitchSpeech.title = @"PitchDemo";
    
    ChatThread *featureDocument = [[ChatThread alloc] init];
    featureDocument.title = @"FeaturePlanning";
    
    ChatThread *collabot = [[ChatThread alloc] init];
    collabot.title = @"Collabot";
    collabot.isDirectMessageThread = TRUE;
    
    [self.chatThreads addObject:pitchSpeech];
    [self.chatThreads addObject:featureDocument];
    [self.chatThreads addObject:collabot];
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
