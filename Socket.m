//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <SecurityFoundation/SFAuthorization.h>

#import "Socket.h"
#import "JSON.h"
#import "Messages.h"

// n2n includes
#include "edge.h"

@implementation Socket

- (id)init {
    if(self = [super init]){
        NSLog(@"init socket");
        host = [NSHost currentHost];

        NSCalendarDate *now = [NSCalendarDate calendarDate];


        [serverAnswerField setObjectValue:[host name]];
        [self openSocket];

        // check on sleep and close socket
        NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
        [nc addObserver:self
               selector:@selector(cleanupBeforeSleep)
                   name:NSWorkspaceWillSleepNotification
                 object:nil];

    }
    return self;
}

- (void)cleanupBeforeSleep {
	[self closeStreams];
}

- (void)openSocket {
	// only do something if stream are not OK (not open)
	if (![self streamsAreOk]) {
        socketAuthenticated = NO;

		host = [NSHost hostWithAddress:@"127.0.0.1"];
		[NSStream getStreamsToHost:host port:5000 inputStream:&inputStream outputStream:&outputStream];
		[self openStreams];
	}
}

- (void)authenticateSocket {
	SBJsonParser *parser = [[SBJsonParser alloc] init];

	// Prepare URL request to get our authentication token
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/sessions/create_token.json?login=dudemeister&password=geheim"]];

	// Perform request and get JSON back as a NSData object
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

	// Get JSON as a NSString from NSData response
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

	NSDictionary *authentication_dict = [parser objectWithString:json_string];

	NSLog(@"%@", json_string);
	NSLog(@"%@", [authentication_dict objectForKey:@"token"]);

	// Now send the authentication-request
	[self sendText:[NSString stringWithFormat:@"{\"operation\":\"authenticate\", \"payload\":{\"user_id\": %@, \"token\": \"%@\"}}",
					[authentication_dict objectForKey:@"user_id"], [authentication_dict objectForKey:@"token"]]];

}

- (void)openStreams {
    [inputStream retain];
    [outputStream retain];
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)closeStreams {
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    [inputStream release];
    [outputStream release];
    inputStream = nil;
    outputStream = nil;
}

- (IBAction)sendMessageAndClearInput:(id)sender {
	[self streamsAreOk];
    [self sendText:[NSString stringWithFormat:@"%@", [inputField stringValue]]];
	[inputField setStringValue:@""];
}

- (void)sendText:(NSString *)string {
    NSString * stringToSend = [NSString stringWithFormat:@"%@\n", string];
    NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    if (outputStream && [self streamsAreOk]) {
        int remainingToWrite = [dataToSend length];
        void * marker = (void *)[dataToSend bytes];
        while (0 < remainingToWrite) {
            int actuallyWritten = 0;
            actuallyWritten = [outputStream write:marker maxLength:remainingToWrite];
            remainingToWrite -= actuallyWritten;
            marker += actuallyWritten;
        }
    } else {
		[serverAnswerField setStringValue:@"trying to open socket, try again!"];
	}

}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    NSInputStream * istream;
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:;
            uint8_t oneByte;
            int actuallyRead = 0;
            istream = (NSInputStream *)aStream;
            if (!dataBuffer) {
                dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
            }
            actuallyRead = [istream read:&oneByte maxLength:1];
            if (actuallyRead == 1) {
                [dataBuffer appendBytes:&oneByte length:1];
            }
            if (oneByte == '\n' || oneByte == '\0') {
					// We've got the carriage return at the end of the echo. Let's set the string.
                NSString * string = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
				[serverAnswerField setStringValue:string];
				[[Messages sharedController] addMessageToTweets:string];
                [string release];
                [dataBuffer release];
                dataBuffer = nil;
            }
            break;
        case NSStreamEventErrorOccurred:
            [self closeStreams];
            [NSTimer scheduledTimerWithTimeInterval:(60.0f/4) target:self selector:@selector(openSocket) userInfo:nil repeats:NO];
            break;
        case NSStreamEventHasSpaceAvailable:
            if (aStream == outputStream) {
                if (!socketAuthenticated) {
                    [self authenticateSocket];
                    socketAuthenticated = YES;
                }
            }
            break;
        case NSStreamEventEndEncountered:
        default:
            break;
    }
}

- (BOOL)streamsAreOk {
	if ([inputStream streamStatus] == NSStreamStatusOpen &&
		[outputStream streamStatus] == NSStreamStatusOpen) {
		NSLog(@"streams are ok!");
		return YES;
	} else {
		NSLog(@"streams are NOT ok!");
		return NO;
	}
}

- (BOOL)streamsAreOpening {
	if ([inputStream streamStatus] == NSStreamStatusOpening &&
		[outputStream streamStatus] == NSStreamStatusOpening) {
		NSLog(@"streams are opening!");
		return YES;
	} else {
		NSLog(@"streams are NOT opening!");
		return NO;
	}	
}

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super dealloc];
}


/**
 * Socket functions and callbacks
 */


@end
