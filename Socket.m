//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Socket.h"


@implementation Socket

- (id)init
{
    [super init];
	
    NSLog(@"init");
	
	tweetList = [[NSMutableArray alloc] initWithCapacity:10];
	
    return self;
}

- (void)awakeFromNib
{	
    host = [NSHost currentHost];
	
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];
	
	[serverAnswerField setObjectValue:[host	name]];
	[self openSocket];
	
	NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
	
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem retain];
	
    [statusItem setTitle: NSLocalizedString(@"Socket",@"")];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menuBar];
	
}

- (void)createStatusBarItem
{
	
}

// todo: rename to sendMessageAndClearInput or so
- (void)send:(id)sender
{	
	[self streamsAreOk];
    [self sendText:[NSString stringWithFormat:@"%@", [inputField stringValue]]];
	[inputField setStringValue:@""];
}

- (IBAction)clearMessages:(id)sender
{
	[tweetList removeAllObjects];
	[tableView reloadData];
}

- (void)openSocket
{
	host = [NSHost hostWithAddress:@"127.0.0.1"];
	[NSStream getStreamsToHost:host port:5000 inputStream:&inputStream outputStream:&outputStream];
	[self openStreams];
	if([self streamsAreOk] || [self streamsAreOpening]) {
		[self sendText:@"initialzing!"];
	} else {
		[serverAnswerField setStringValue:@"no socket available"];
	}
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
		// try to open the socket
		[self openSocket];
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
				[self addMessageToTweets:string];
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

- (BOOL)streamsAreOk {
	if ([inputStream streamStatus] == 2 && [outputStream streamStatus] == 2) {
		NSLog(@"streams are ok!");
		return YES;
	} else {
		NSLog(@"streams are NOT ok!");
		return NO;
	}
}

- (BOOL)streamsAreOpening {
	if ([inputStream streamStatus] == 1 && [outputStream streamStatus] == 1) {
		NSLog(@"streams are opening!");
		return YES;
	} else {
		NSLog(@"streams are NOT opening!");
		return NO;
	}	
}

- (int)numberOfRowsInTableView:(NSTableView *)tv {
    return [tweetList count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    NSString *value = [tweetList objectAtIndex:row];
    return value;
}

- (void)addMessageToTweets:(NSString *)string {
	// add the message to the beginning of the message array
	[tweetList insertObject:string atIndex:0];
	[tableView reloadData];
	//NSLog(@"currently %@ in array", [tweetList count]);
}

@end
