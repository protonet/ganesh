//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Socket : NSObject {
	IBOutlet NSTextField *inputField;
	IBOutlet NSTextField *serverAnswerField;
	NSInputStream *inputStream;
	NSOutputStream *outputStream;
	NSMutableData * dataBuffer;
	NSHost * host;	
}

- (IBAction)send:(id)sender;
- (void)openSocket;
- (void)openStreams;
- (void)closeStreams;
- (void)sendText:(NSString *)string;

@end
