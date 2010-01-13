//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Socket.h"
#import "JSON.h"

@implementation Socket

- (id)init {
    [super init];
	
    NSLog(@"init");
	preferences = [[PreferenceController alloc] init];
	NSLog(@"%@", [preferences serverAddress]);
	tweetList = [[NSMutableArray alloc] initWithCapacity:10];
	
	messageCounter = 0;
	socketAuthenticated = NO;
	
    return self;
}

- (void)awakeFromNib {	
    host = [NSHost currentHost];
	
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];
	
    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];
	
	// allocate and load the images into the app
	statusNoVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive" ofType:@"png"]];
    statusNoVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive_message" ofType:@"png"]];	
	
	statusHasVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active" ofType:@"png"]];
	statusHasVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active_message" ofType:@"png"]];
	
	[serverAnswerField setObjectValue:[host	name]];
	[self openSocket];
	[self createStatusBarItem];
	
	// periodically check socket and reopen if needed
	[NSTimer scheduledTimerWithTimeInterval:(10.0f) target:self selector:@selector(openSocket) userInfo:nil repeats:YES];	
	// check on sleep and close socket
	NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self
           selector:@selector(applicationWillTerminate)
               name:NSWorkspaceWillSleepNotification
             object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillTerminate)
												 name:NSApplicationWillTerminateNotification object:nil];
	
}

- (void)applicationWillTerminate
{
	[self closeStreams];
}

- (void)createStatusBarItem {
	NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
	
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem retain];
	[statusItem setImage:statusNoVpnNoMessageImage];
    [statusItem setHighlightMode:YES];
	[statusItem setAction:@selector(pushedStatusBarItem:)];
	[statusItem setTarget:self];
}

- (IBAction)pushedStatusBarItem:(id)sender {
	[self resetStatusBarItem];
	[statusItem popUpStatusItemMenu:menuForStatusItem];
}

- (void)notifyStatusBarItem
{
	[statusItem setImage:statusNoVpnHasMessageImage];
}

- (void)resetStatusBarItem
{
	[statusItem setImage:statusNoVpnNoMessageImage];
}

- (void)addMenuItemForTweet:(Tweet *)tweet {
	NSMenuItem *subMenuItem = [[[NSMenuItem alloc] initWithTitle:tweet.message action:@selector(openPtnDashboard:) keyEquivalent:@""] autorelease];
	[subMenuItem setImage:tweet.userImage];
	[subMenuItem setTarget:self];
	[menuForStatusItem insertItem:subMenuItem atIndex:2];
	if (messageCounter > 5) {
		[menuForStatusItem removeItemAtIndex:7];
		messageCounter--;
	}
}

- (void)openPtnDashboard:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[preferences serverUrl]]];
}

- (IBAction)sendMessageAndClearInput:(id)sender {	
	[self streamsAreOk];
    [self sendText:[NSString stringWithFormat:@"%@", [inputField stringValue]]];
	[inputField setStringValue:@""];
}

- (IBAction)clearMessages:(id)sender {
	[tweetList removeAllObjects];
	[tableView reloadData];
}

- (void)openSocket {
	// only do something if stream are not OK (not open)
	if (![self streamsAreOk]) {
		host = [NSHost hostWithAddress:[preferences serverAddress]];
		[NSStream getStreamsToHost:host port:5000 inputStream:&inputStream outputStream:&outputStream];
		[self openStreams];
		// is this a good idea?
		sleep(1);
		if([self streamsAreOk] || [self streamsAreOpening]) {
			[self authenticateSocket];
		} else {
			[serverAnswerField setStringValue:@"no socket available"];
		}		
	}
}

- (void)authenticateSocket {
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSString *authentication_url = [NSString stringWithFormat:@"%@/sessions/create_token.json?login=%@&password=%@", [preferences serverUrl], [preferences username], [preferences password]];

	// Prepare URL request to get our authentication token
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authentication_url]];
	
	// Perform request and get JSON back as a NSData object
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	// Get JSON as a NSString from NSData response
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSDictionary *authentication_dict = [parser objectWithString:json_string];

    NSLog(@"%@", json_string);
	NSLog(@"%@", [authentication_dict objectForKey:@"token"]);
	
	if([authentication_dict objectForKey:@"user_id"]) {
		// Now send the authentication-request
		[self sendText:[NSString stringWithFormat:@"{\"operation\":\"authenticate\", \"payload\":{\"user_id\": %@, \"token\": \"%@\"}}",
						[authentication_dict objectForKey:@"user_id"], [authentication_dict objectForKey:@"token"]]];
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
	NSLog(@"closed sockets!");
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
	SBJsonParser *parser = [[SBJsonParser alloc] init];

	Tweet * tweet = [[Tweet alloc] initWithData:[parser objectWithString:string]];
	
	if (tweet) {
		messageCounter++ ;
		[self notifyStatusBarItem];
		// add the message to the beginning of the message array
		[tweetList insertObject:string atIndex:0];
		[tableView reloadData];
		//NSLog(@"currently %@ in array", [tweetList count]);
		[self addMenuItemForTweet:tweet];		
	}
}

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super dealloc];
	
}

@end
