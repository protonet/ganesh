//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Socket : NSObject {
	IBOutlet NSTextField * serverAnswerField;
	NSInputStream * inputStream;
	NSOutputStream * outputStream;
    NSMutableData * dataBuffer;
    NSMutableData * responseData;
	NSHost * host;
	
	BOOL authenticated;

    NSString *serverUrl;
    NSString *serverAddress;
    NSNumber *serverPort;
    NSString *userName;
    NSString *password;
    NSString *authenticityToken;
    NSArray  *cookies;
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
- (BOOL)streamsAreOpening;
- (void)sendText:(NSString *)string;


@end
