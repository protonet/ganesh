//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class Reachability;
@class AsyncSocket;
@interface Socket : NSObject {
    AsyncSocket *asyncSocket;
    NSMutableData * dataBuffer;

    NSHost * host;

    BOOL authenticated;

    NSString *serverUrl;
    NSString *serverAddress;
    NSNumber *serverPort;
    NSString *userName;
    NSString *password;
    NSString *authenticityToken;
    NSArray  *cookies;

    Reachability* internetReach;
}

@property(assign) BOOL authenticated;
@property(retain) NSString *serverUrl;
@property(retain) NSString *serverAddress;
@property(retain) NSNumber *serverPort;
@property(retain) NSString *userName;
@property(retain) NSString *password;
@property(retain) NSString *authenticityToken;
@property(retain) NSArray  *cookies;

- (void)sendMessage:(NSString*)message;
- (void)openSocket;
- (void)openStreams;
- (void)closeStreams;
- (void)authenticateSocket;
- (void)initPreferences;

- (BOOL)streamsAreOk;
- (void)sendText:(NSString *)string;


@end
