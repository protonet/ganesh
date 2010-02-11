//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Socket : NSObject {
	
	NSUserDefaults * defaults;
	
	IBOutlet NSTextField * inputField;
	IBOutlet NSTextField * serverAnswerField;
	NSInputStream * inputStream;
	NSOutputStream * outputStream;
	NSMutableData * dataBuffer;
	NSHost * host;
	
	BOOL socketAuthenticated;
	
}

- (IBAction)sendMessageAndClearInput:(id)sender;

- (void)openSocket;
- (void)openStreams;
- (void)closeStreams;
- (void)authenticateSocket;

- (BOOL)streamsAreOk;
- (BOOL)streamsAreOpening;
- (void)sendText:(NSString *)string;


@end
