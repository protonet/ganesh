//
//  AppController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <SecurityFoundation/SFAuthorization.h>

#import "AppController.h"
#import "PrefsController.h"
#import "JSON.h"
#import "Messages.h"
#import "GrowlNotifier.h"

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

static AppController *sharedAppController = nil;

@implementation AppController

+ (AppController*)sharedController
{
    if (sharedAppController == nil) {
        sharedAppController = [[super allocWithZone:NULL] init];
    }
    return sharedAppController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)awakeFromNib
{
    if([self checkAndCopyHelper]){
        [self runApp];
    }

	tweetList = [[NSMutableArray alloc] initWithCapacity:10];

    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];

    // allocate and load the images into the app
    statusNoVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive" ofType:@"png"]];
    statusNoVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive_message" ofType:@"png"]];	

    statusHasVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active" ofType:@"png"]];
    statusHasVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active_message" ofType:@"png"]];

	[self createStatusBarItem];
    // TODO: does this need a dealloc socket release?
    socket = [[Socket alloc] init];
	
    [self observeMessages];

}

- (void) dealloc
{
    [socket release];
    [super dealloc];
}

- (IBAction)openPreferences:(id)sender
{
    [[PrefsController sharedController] showWindow:nil];
}

- (void)observeMessages
{
    [[Messages sharedController] addObserver:self
                                  forKeyPath:@"messages"
                                     options:(NSKeyValueObservingOptionNew |
                                              NSKeyValueObservingOptionOld)
                                     context:nil];

    [socket addObserver:self
             forKeyPath:@"authenticated"
                options:(NSKeyValueObservingOptionNew |
                         NSKeyValueObservingOptionOld)
                context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"messages"]) {
        [self addMenuItemForTweet];

    }
    else if([keyPath isEqual:@"authenticated"]){
        [self updateStatusBarItem];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"app will terminate");
    [n2nApp terminate];
    [n2nApp waitUntilExit];
    [n2nApp release];

}

/**
 * menubar item methods
 */
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
    [statusItem popUpStatusItemMenu:statusMenu];
}

- (void)updateStatusBarItem {
    if(socket.authenticated){
        [statusItem setImage:statusNoVpnHasMessageImage];
    } else {
        [statusItem setImage:statusNoVpnNoMessageImage];
    }

}

- (NSMenuItem *)buildTweetMenuItem
{
    // get last tweet from messages
    Tweet *tweet = [[Messages sharedController] first];
    // growl notification for tweet
    [[GrowlNotifier sharedController] showNewTweet:tweet];

    NSMenuItem *subMenuItem = [[[NSMenuItem alloc] initWithTitle:tweet.message action:@selector(openPtnDashboard:) keyEquivalent:@""] autorelease];
    [subMenuItem setImage:tweet.userImage];
    [subMenuItem setTarget:self];
	return subMenuItem;
}

- (void)addMenuItemForTweet{
    NSMenuItem *subMenuItem = [self buildTweetMenuItem];
    [statusMenu insertItem:subMenuItem atIndex:3];
    if ([[Messages sharedController] count] > MAX_TWEETS) {
        [statusMenu removeItemAtIndex:MAX_TWEETS+3];
    }
}

- (void)openPtnDashboard:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:3000/"]];
}

- (void)resetStatusBarItem {
	//[statusItem setTitle: [NSString stringWithFormat:@"Socket"]];
	[self updateStatusBarItem];
}

- (IBAction)clearMessages:(id)sender {
    [[Messages sharedController] clear];
	[tableView reloadData];
}


/**
 * tableview delegates
 */
- (int)numberOfRowsInTableView:(NSTableView *)tv {
    return [tweetList count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
    NSString *value = [tweetList objectAtIndex:row];
    return value;
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
    n2nApp = [[NSTask alloc] init];

    NSString *n2nPath = [NSString stringWithFormat:@"%@/n2n.app/Contents/MacOS/n2n", [self appSupportPath]];
    [n2nApp setLaunchPath:n2nPath];
    [n2nApp launch];
    /*
    if ([n2nApp isRunning]) {
        [daemonButton setTitle:@"Stop"];
        [daemonButton setAction:@selector(stopDaemon:)];
    }
    */
}

- (void) stopDaemon:(id)sender
{
    if ([n2nApp isRunning]) {
        [n2nApp terminate];
        [n2nApp release];
        n2nApp = nil;
        /*
        [daemonButton setTitle:@"Start"];
        [daemonButton setAction:@selector(startDaemon:)];
        */
    }
}

- (void)startDaemon:(id)sender
{
    if (n2nApp == nil){
        [self runApp];
    }
}


- (IBAction)connect:(id)sender {
    [statusItem setImage:statusHasVpnNoMessageImage];
    [statusMenu removeItemAtIndex:0];
    [statusMenu insertItemWithTitle:@"Disconnect..." action:@selector(disconnect:) keyEquivalent:@"" atIndex:0];
    [[statusMenu itemAtIndex:0] setTarget:self];


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
        const char* const argumentLists[][5] = {
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
    [statusMenu removeItemAtIndex:0];
    [statusMenu insertItemWithTitle:@"Connect..." action:@selector(connect:) keyEquivalent:@"" atIndex:0];
    [[statusMenu itemAtIndex:0] setTarget:self];

    [[NSDistributedNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:@"N2NEdgeDisconnect" object:nil]];
}

- (IBAction)postMessage:(id)sender
{
    [socket sendMessage:[postField stringValue]];
    [postField setStringValue:@""];
}

- (IBAction)showNewMessage:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    if (![postWindow isVisible])
        [postWindow center];
    [postWindow makeKeyAndOrderFront:nil];
}

@end
