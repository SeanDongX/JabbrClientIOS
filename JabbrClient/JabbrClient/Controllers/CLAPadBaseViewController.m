//
//  CLAPadBaseViewController.m
//  Collara
//
//  Created by Sean on 12/04/15.
//  Copyright (c) 2015 Collara. All rights reserved.
//

#import "CLAPadBaseViewController.h"
//#import "SRConnection.h"

@interface CLAPadBaseViewController ()

@end

@implementation CLAPadBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self connectSocket];
}

- (void)connectSocket {
    
    NSTimeInterval time = [NSDate date].timeIntervalSince1970 * 1000;
    NSString *endpoint =
    [NSString stringWithFormat:@"http://192.168.31.194:9001/socket.io/"
     @"?EIO=3&transport=polling&t=%ld-0",
     (long)time];
    
    // TOOD: use session http://www.teehanlax.com/blog/how-to-socket-io-swift/
    // and read cookie for later use
    [NSURLConnection
     sendAsynchronousRequest:[NSURLRequest
                              requestWithURL:[NSURL URLWithString:endpoint]]
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data,
                         NSError *error) {
         
         // NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse
         // *)response;
         
         if (error == nil) {
             
             NSString *decodedString = [self octecStreamDataToString:data];
             NSData *data =
             [decodedString dataUsingEncoding:NSUTF8StringEncoding];
             
             id json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                         error:nil];
             
             if (error) {
                 /* JSON was malformed, act appropriately here */
             }
             
             if ([json isKindOfClass:[NSDictionary class]]) {
                 NSDictionary *results = json;
                 
                 NSString *handshakeToken = [results objectForKey:@"sid"];
                 NSLog(@"HANDSHAKE %@", handshakeToken);
             }
         }
     }];
}

- (NSString *)octecStreamDataToString:(NSData *)data {
    const unsigned char *dbytes = [data bytes];
    NSInteger length = [data length];
    NSMutableString *dataString = [NSMutableString stringWithCapacity:length];
    int i;
    for (i = 0; i < length; i++) {
        [dataString appendFormat:@"%c", dbytes[i]];
    }
    
    // TODO: find json string from { to }
    return [dataString substringFromIndex:4];
}

- (void)socketConnect:(NSString *)token {
    
    SRWebSocket *socketio = [[SRWebSocket alloc]
                             initWithURL:[NSURL URLWithString:
                                          [NSString stringWithFormat:@"ws://localhost:9001/"
                                           @"socket.io/"
                                           @"?EIO=3&transport="
                                           @"websocket&sid=%@",
                                           token]]];
    socketio.delegate = self;
    [socketio open];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received message");
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"opened");
    // TODO: send client ready like pad.js
    //                                       socket.once('connect', function () {
    //                                           sendClientReady(false);
    //                                       });
    //                                       function sendClientReady(isReconnect,
    //                                       messageType)
    //                                       {
    //                                           messageType = typeof messageType
    //                                           !== 'undefined' ? messageType :
    //                                           'CLIENT_READY';
    //                                           var padId =
    //                                           document.location.pathname.substring(document.location.pathname.lastIndexOf("/")
    //                                           + 1);
    //                                           padId =
    //                                           decodeURIComponent(padId); //
    //                                           unescape neccesary due to Safari
    //                                           and Opera interpretation of
    //                                           spaces
    //
    //                                           if(!isReconnect)
    //                                           {
    //                                               var titleArray =
    //                                               document.title.split('|');
    //                                               var title =
    //                                               titleArray[titleArray.length
    //                                               - 1];
    //                                               document.title =
    //                                               padId.replace(/_+/g, ' ') + "
    //                                               | " + title;
    //                                           }
    //
    //                                           var token = readCookie("token");
    //                                           if (token == null)
    //                                           {
    //                                               token = "t." +
    //                                               randomString();
    //                                               createCookie("token", token,
    //                                               60);
    //                                           }
    //
    //                                           var sessionID =
    //                                           decodeURIComponent(readCookie("sessionID"));
    //                                           var password =
    //                                           readCookie("password");
    //
    //                                           var msg = {
    //                                               "component": "pad",
    //                                               "type": messageType,
    //                                               "padId": padId,
    //                                               "sessionID": sessionID,
    //                                               "password": password,
    //                                               "token": token,
    //                                               "protocolVersion": 2
    //                                           };
    //
    //                                           //this is a reconnect, lets tell
    //                                           the server our revisionnumber
    //                                           if(isReconnect == true)
    //                                           {
    //                                               msg.client_rev=pad.collabClient.getCurrentRevisionNumber();
    //                                               msg.reconnect=true;
    //                                           }
    //
    //                                           socket.json.send(msg);
    //                                       }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"error");
}
- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean {
    NSLog(@"close with code %ld, reason: %@", (long)code, reason);
}

@end
