//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@class Reachability;
@class AsyncSocket;
@class NetworksDataSource;
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
    NSArray  *cookies;

    NSTimer  *reconnTimer;
    NSTimer  *pingTimer;

    Reachability* internetReach;
    NetworksDataSource *networksDataSource;
}

@property(assign) BOOL authenticated;
@property(retain) NSString *serverUrl;
@property(retain) NSString *serverAddress;
@property(retain) NSNumber *serverPort;
@property(retain) NSString *userName;
@property(retain) NSString *password;
@property(retain) NSArray  *cookies;
@property(retain) NSTimer  *reconnTimer;
@property(retain) NSTimer  *pingTimer;

- (void)sendMessage:(NSString*)message;
- (void)openSocket;
- (void)openStreams;
- (void)closeStreams;
- (void)authenticateSocket;
- (void)initPreferences;

- (BOOL)streamsAreOk;
- (void)sendText:(NSString *)string;


@end
