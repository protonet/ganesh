//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Socket.h"


@implementation Socket
- (void)send:(id)sender
{	
    [self sendText:[NSString stringWithFormat:@"%@", [inputField stringValue]]];
	[inputField setStringValue:@""];
}

- (void)awakeFromNib
{
	NSHost *host;
	
    host = [NSHost currentHost];
	
	NSLog(@"foooovar");
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];
	[serverAnswerField setObjectValue:[host	name]];
	[self openSocket];
	[self sendText:@"whazzzupbitches!"];
}

- (void)openSocket
{
	host = [NSHost hostWithAddress:@"127.0.0.1"];
	[NSStream getStreamsToHost:host port:5000 inputStream:&inputStream outputStream:&outputStream];
	[self openStreams];
	
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

- (void)sendText:(NSString *)string {
    NSString * stringToSend = [NSString stringWithFormat:@"%@\n", string];
    NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    if (outputStream) {
        int remainingToWrite = [dataToSend length];
        void * marker = (void *)[dataToSend bytes];
        while (0 < remainingToWrite) {
            int actuallyWritten = 0;
            actuallyWritten = [outputStream write:marker maxLength:remainingToWrite];
            remainingToWrite -= actuallyWritten;
            marker += actuallyWritten;
        }
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
            if (oneByte == '\n') {
					// We've got the carriage return at the end of the echo. Let's set the string.
                NSString * string = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
				[serverAnswerField setStringValue:string];
                [string release];
                [dataBuffer release];
                dataBuffer = nil;
            }
            break;
        case NSStreamEventEndEncountered:;
            [self closeStreams];
            break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
        case NSStreamEventOpenCompleted:
        case NSStreamEventNone:
        default:
            break;
    }
}

@end
