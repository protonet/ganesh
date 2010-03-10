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
#import "Debug.h"

#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

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

	[self createStatusBarItem];
    // autohide timeline window
    [timelineWindow setHidesOnDeactivate:YES];
    [self renderTemplate];
    // TODO: does this need a dealloc socket release?
    socket = [[Socket alloc] init];
	
    [self observeMessages];
}

- (void) dealloc
{
    [statusItemView release];
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
        // get last tweet from messages
        Tweet *tweet = [[Messages sharedController] first];
        if(!tweet.isOwn){
            // growl notification for tweet
            [[GrowlNotifier sharedController] showNewTweet:tweet];
            statusItemView.newMessage = YES;
            [statusItemView update];
        }
        [self renderTemplate];
    }
    else if([keyPath isEqual:@"authenticated"]){
        statusItemView.connected = socket.authenticated;
        [statusItemView update];
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

    statusItem = [systemStatusBar statusItemWithLength:22];
    [statusItem retain];
    statusItemView = [[GaneshStatusView alloc] init];
    [statusItemView retain];
    statusItemView.statusItem = statusItem;
    [statusItemView setMenu:statusMenu];
    [statusItem setView:statusItemView];
    [statusItem setHighlightMode:YES];
}

- (void)renderTemplate{
    // Set up template engine with your chosen matcher.
	MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
	[engine setDelegate:self];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
	
	// Set up any needed global variables.
	// Global variables persist for the life of the engine, even when processing multiple templates.
	[engine setObject:@"Hi there!" forKey:@"hello"];
	
	// Get path to template.
	NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"html" inDirectory:@"/Light.bbtheme"];
	
	// Set up some variables for this specific template.
	
    NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys: 
							   [Messages sharedController].messages, @"tweets", 
							   nil];
	
	// Process the template and display the results.
	NSString *result = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
	DLog(@"Processed template:\r%@", result);
    
    //HTML Encode the Resource Path of the main bundle and change single slashes to double slashes
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingPathComponent:@"Light.bbtheme"];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    resourcePath = [NSString stringWithFormat:@"file:/%@//",resourcePath];
    NSURL *resourceUrl = [NSURL URLWithString:resourcePath];
    [[webView mainFrame] loadHTMLString:result baseURL:resourceUrl];
}

- (void)openPtnDashboard:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:3000/"]];
}

- (IBAction)clearMessages:(id)sender {
    [[Messages sharedController] clear];
	[tableView reloadData];
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
//    [statusItem setImage:statusHasVpnNoMessageImage];
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
//    [statusItem setImage:statusNoVpnNoMessageImage];
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

- (IBAction)showTimeline:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [timelineWindow makeKeyAndOrderFront:nil];
}


// ****************************************************************
// 
// Methods below are all optional MGTemplateEngineDelegate methods.
// 
// ****************************************************************


- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}


@end
