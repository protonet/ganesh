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

// n2n includes
#include "edge.h"

static BOOL AuthorizationExecuteWithPrivilegesAndWait(AuthorizationRef authorization, const char* executablePath, AuthorizationFlags options, const char* const* arguments)
{
    sig_t oldSigChildHandler = signal(SIGCHLD, SIG_DFL);
    BOOL returnValue = YES;

    if (AuthorizationExecuteWithPrivileges(authorization, executablePath, options, (char* const*)arguments, NULL) == errAuthorizationSuccess)
    {
        int status;
        pid_t pid = wait(&status);
        if (pid == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0)
            returnValue = NO;
    }
    else
        returnValue = NO;

    signal(SIGCHLD, oldSigChildHandler);
    return returnValue;
}


@implementation Socket

- (id)init {
    [super init];
	
    NSLog(@"init");
	
	tweetList = [[NSMutableArray alloc] initWithCapacity:10];
	
	messageCounter = 0;
	socketAuthenticated = NO;
	
    return self;
}

- (void)awakeFromNib {	
    if([self checkAndCopyHelper]){
        [self runApp];
    }

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
	[NSTimer scheduledTimerWithTimeInterval:(60.0f/4) target:self selector:@selector(openSocket) userInfo:nil repeats:YES];	
	// check on sleep and close socket
	NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self
           selector:@selector(applicationWillTerminate)
               name:NSWorkspaceWillSleepNotification
             object:nil];
	
}

- (void)cleanupBeforeSleep {
	[self closeStreams];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"app will terminate");
    [n2nApp terminate];
    [n2nApp waitUntilExit];
    [n2nApp release];

    [self cleanupBeforeSleep];
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

- (void)updateStatusBarItem {
	if (messageCounter > 0) {
		[statusItem setImage:statusNoVpnHasMessageImage];
	} else {
		[statusItem setImage:statusNoVpnNoMessageImage];
	}

}

- (void)resetStatusBarItem {
	//[statusItem setTitle: [NSString stringWithFormat:@"Socket"]];
	messageCounter = 0;
	[self updateStatusBarItem];
}

- (void)addMenuItemForTweet:(Tweet *)tweet {
	NSMenuItem *subMenuItem = [[[NSMenuItem alloc] initWithTitle:tweet.message action:@selector(openPtnDashboard:) keyEquivalent:@""] autorelease];
	[subMenuItem setImage:tweet.userImage];
	[subMenuItem setTarget:self];
	[menuForStatusItem insertItem:subMenuItem atIndex:3];
	if (messageCounter > 5) {
		[menuForStatusItem removeItemAtIndex:8];
	}
}

- (void)openPtnDashboard:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:3000/"]];
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
		host = [NSHost hostWithAddress:@"127.0.0.1"];
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
				[self updateStatusBarItem];					
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


//*************************************************************//
/**
 * ganesh stuff
 * @todo: move this code out of the socket.m
 */
- (BOOL) checkAndCopyHelper
{
    NSError *error;
    NSDictionary *srcAttributes;
    NSDictionary *dstAttributes;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"n2n" ofType:@"app"];
    NSString *dstPath = [NSString stringWithFormat:@"%@/n2n.app", [self appSupportPath]];


    [fileManager createDirectoryAtPath:[self appSupportPath]
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];
    srcAttributes = [fileManager attributesOfItemAtPath:srcPath error:&error];
    dstAttributes = [fileManager attributesOfItemAtPath:dstPath error:&error];

    if (dstAttributes != nil && [[srcAttributes fileModificationDate] compare:[dstAttributes fileModificationDate]] == NSOrderedSame ) {
        return YES;
    }
    else {
        return [self copyPathWithforcedAuthentication:srcPath toPath:dstPath error:&error];
    }

}

- (NSString *) appSupportPath
{
    FSRef folder;
    OSErr err = noErr;
    CFURLRef url;
    NSString *userAppSupportFolder;
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];

    /* (C) ~/Library/Application Support
	 The user's application support folder.  Attempt to locate the folder, but
	 do not try to create one if it does not exist.  */
    err = FSFindFolder( kUserDomain, kApplicationSupportFolderType, false, &folder );
    if ( noErr == err ) {
        url = CFURLCreateFromFSRef( kCFAllocatorDefault, &folder );

        if ( url != NULL ) {
            userAppSupportFolder = [NSString stringWithFormat:@"%@/%@",
									[(NSURL *)url path], applicationName];
        }

    }
    return userAppSupportFolder;
}

/**
 * run n2n.app from resources
 */
- (void)runApp{

    // [run setLaunchPath: @"/usr/bin/open"];
    NSString *n2nPath = [NSString stringWithFormat:@"%@/n2n.app/Contents/MacOS/n2n", [self appSupportPath]];
    [n2nApp setLaunchPath:n2nPath];
    // NSArray *arguments = [NSArray arrayWithObjects: n2nPath, nil];
    // [n2nApp setArguments: arguments];
    [n2nApp launch];
	/*
    if ([n2nApp isRunning]) {
        [daemonButton setTitle:@"Stop"];
        [daemonButton setAction:@selector(stopDaemon:)];
    }
	 */
}

- (IBAction)connect:(id)sender {
    [statusItem setImage:statusHasVpnNoMessageImage];
    [menuForStatusItem removeItemAtIndex:0];
    [menuForStatusItem insertItemWithTitle:@"Disconnect..." action:@selector(disconnect:) keyEquivalent:@"" atIndex:0];


    [[NSDistributedNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:@"N2NEdgeConnect" object:nil]];
}

- (BOOL) copyPathWithforcedAuthentication:(NSString *)src toPath:(NSString *)dst error:(NSError **)error
{
    const char* srcPath = [src fileSystemRepresentation];
    const char* dstPath = [dst fileSystemRepresentation];
    const char* execPath = [[NSString stringWithFormat:@"%@/Contents/Resources/TunHelper", dst] fileSystemRepresentation];

    AuthorizationRef auth = NULL;
    OSStatus authStat = errAuthorizationDenied;
    while (authStat == errAuthorizationDenied) {
        authStat = AuthorizationCreate(NULL,
                                       kAuthorizationEmptyEnvironment,
                                       kAuthorizationFlagDefaults,
                                       &auth);
    }

    BOOL res = NO;
    if (authStat == errAuthorizationSuccess) {
        res = YES;

        char uidgid[42] = "root:wheel";

        const char* executables[] = {
            "/bin/rm",
            "/bin/cp",
            NULL,  // pause here and do some housekeeping before
            // continuing
            "/usr/sbin/chown",
            "/bin/chmod",
            NULL   // stop here for real
        };

        // 4 is the maximum number of arguments to any command,
        // including the NULL that signals the end of an argument
        // list.
        const char* const argumentLists[][4] = {
            { "-rf", dstPath, NULL }, // delete the destination
            { "-R", "-p", srcPath, dstPath, NULL },  // cp
            { NULL },  // pause
            { "-R", uidgid, dstPath, NULL },  // chown
            { "+s", execPath, NULL },  // chmod
            { NULL }  // stop
        };

        // Process the commands up until the first NULL
        int commandIndex = 0;
        for (; executables[commandIndex] != NULL; ++commandIndex) {
            if (res)
                res = AuthorizationExecuteWithPrivilegesAndWait(auth, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
        }

        // Now move past the NULL we found and continue executing
        // commands from the list.
        ++commandIndex;

        for (; executables[commandIndex] != NULL; ++commandIndex) {
            if (res)
                res = AuthorizationExecuteWithPrivilegesAndWait(auth, executables[commandIndex], kAuthorizationFlagDefaults, argumentLists[commandIndex]);
        }

        AuthorizationFree(auth, 0);

        if (!res)
        {
            // Something went wrong somewhere along the way, but we're not sure exactly where.
            NSString *errorMessage = [NSString stringWithFormat:@"Authenticated file copy from %@ to %@ failed.", src, dst];
            // if (error != NULL)
                // *error = [NSError errorWithDomain:SUSparkleErrorDomain code:SUAuthenticationFailure userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
        }
    }
    else
    {
        // if (error != NULL)
            // *error = [NSError errorWithDomain:SUSparkleErrorDomain code:SUAuthenticationFailure userInfo:[NSDictionary dictionaryWithObject:@"Couldn't get permission to authenticate." forKey:NSLocalizedDescriptionKey]];
    }
    return res;

}

- (IBAction)disconnect:(id)sender
{
    [statusItem setImage:statusNoVpnNoMessageImage];
    [menuForStatusItem removeItemAtIndex:0];
    [menuForStatusItem insertItemWithTitle:@"Connect..." action:@selector(connect:) keyEquivalent:@"" atIndex:0];

    [[NSDistributedNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:@"N2NEdgeDisconnect" object:nil]];
}


@end
