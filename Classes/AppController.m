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
#import "Messages.h"
#import "GrowlNotifier.h"
#import "LIFOStack.h"
#import "BonjourClientController.h"

#import "Debug.h"

#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"

#import "N2NUserDefaultsController.h"

// n2n includes
#include "edge.h"

static EventHotKeyRef gMyHotKeyRef;

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData)
{
    [[AppController sharedController] showTimeline:nil];
    return noErr;
}


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

- (NSString *)appSupportPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] :NSTemporaryDirectory();
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleName"];
    return [basePath stringByAppendingPathComponent:applicationName];
}

- (NSString *)cachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] :NSTemporaryDirectory();
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    return [basePath stringByAppendingPathComponent:bundleId];
}

- (void) initDefaults
{
    NSString *path;
    NSDictionary *dict;
    path = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (void)installHotkey:(NSInteger)code withFlags:(NSUInteger)flags
{
    //Register the Hotkeys
    EventHotKeyID gMyHotKeyID;

    gMyHotKeyID.signature='htk1';
    gMyHotKeyID.id=1;

    if (gMyHotKeyRef) {
        UnregisterEventHotKey(gMyHotKeyRef);
        gMyHotKeyRef = nil;
    }
    RegisterEventHotKey(code, flags, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);

}


- (void)initializeHotkeys
{
    // initialize hotkeyref to nil just in case
    gMyHotKeyRef = nil;
    // register hotkey event handler
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;

    InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger  code  = [defaults integerForKey:@"toggleTimelineKeycode"];
    NSUInteger flags = [defaults integerForKey:@"toggleTimelineKeyflags"];

    if(code && flags){
        [self installHotkey:code withFlags:flags];
    }
}

- (void)awakeFromNib
{
    cur_networks = 0;

    [self initializeHotkeys];

    [self initDefaults];

    [self registerURLHandler];

    // Init input stack
    inputStack = [[LIFOStack alloc] init];
    [inputStack retain];

    serverConnection=[NSConnection defaultConnection];
    [serverConnection setRootObject:self];
    if(![serverConnection registerName:@"N2NServerConnection"]){
        DLog(@"could not create connection with name N2NServerConnection");
        [NSApp terminate:self];
    }

    if([self checkAndCopyHelper]){
        [self runApp];
    }

    [postField setDelegate:self];
    [postField setTextContainerInset:NSMakeSize(5,8)];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:12]
                   forKey:NSFontAttributeName];

    [postField setTypingAttributes:attributes];

    [self createStatusBarItem];
    [self renderTemplate];
    // TODO: does this need a dealloc socket release?
    socket = [[Socket alloc] init];

    [self observeMessages];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(windowBecameMain:)
               name:NSWindowDidBecomeMainNotification object:nil];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(edgeConnected:)
                                                            name:N2N_CONNECTED
                                                          object:nil];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(edgeDisconnected:)
                                                            name:N2N_DISCONNECTED
                                                          object:nil];

    bonjourClient = [[BonjourClientController alloc] init];
}

- (void) dealloc
{
    [inputStack release];
    [statusItemView release];
    [socket release];
    [bonjourClient release];
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(n2nDidChange:)
                                                 name:@"N2NDefaultsDidSaveChanges"
                                               object:nil];
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
        }
        [self addTweet:tweet];
    }
    else if([keyPath isEqual:@"authenticated"]){
        statusItemView.connected = socket.authenticated;
    }
}

- (void)n2nDidChange:(NSNotification *)aNotification
{
    if(cur_networks > 0){
        for(int i = 1; i <= cur_networks; i++){
            [statusMenu removeItemAtIndex:i];
        }
        cur_networks = 0;
    }

    NSArray *networks = [[N2NUserDefaultsController standardUserDefaults] objectForKey:@"networks"];
    for(NSDictionary *network in networks){
        cur_networks++;
        [statusMenu insertItemWithTitle:[NSString stringWithFormat:@"Connect %@", [network objectForKey:@"description"]]
                                 action:@selector(connect:)
                          keyEquivalent:@""
                                atIndex:cur_networks];
        [[statusMenu itemAtIndex:cur_networks] setTag:cur_networks];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"app will terminate");
    [n2nApp terminate];
    [n2nApp waitUntilExit];
    [n2nApp release];

    Messages *msg = [Messages sharedController];
    if([msg count] > 0){
        NSString *tweetPath = [[self cachePath] stringByAppendingPathComponent:@"tweets"];
        [msg.messages writeToFile:tweetPath atomically:YES];
    }
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

    [self n2nDidChange:nil];
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
	DLog(@"Processed template");
    //HTML Encode the Resource Path of the main bundle and change single slashes to double slashes
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingPathComponent:@"Light.bbtheme"];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    resourcePath = [NSString stringWithFormat:@"file:/%@//",resourcePath];
    NSURL *resourceUrl = [NSURL URLWithString:resourcePath];
    [[webView mainFrame] loadHTMLString:result baseURL:resourceUrl];
}

- (void)addTweet:(Tweet*)tweet{
    // Set up template engine with your chosen matcher.
	MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
	[engine setDelegate:self];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];

	// Get path to template.
	NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"tweet"
                                                             ofType:@"html"
                                                        inDirectory:@"/Light.bbtheme"];

	// Set up some variables for this specific template.

    NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys: tweet, @"tweet", nil];

	// Process the template and display the results.
	NSString *result = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
	DLog(@"Processed template");

    [[webView windowScriptObject] callWebScriptMethod:@"addTweet"
                                        withArguments:[NSArray arrayWithObjects:result,tweet.channel_id,nil]];
}

- (void)setChannel:(NSNumber*)channelId{
    [[webView windowScriptObject] callWebScriptMethod:@"setChannel"
                                        withArguments:[NSArray arrayWithObjects:channelId,nil]];
}

- (void)openPtnDashboard:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:3000/"]];
}

- (IBAction)clearMessages:(id)sender {
    [[Messages sharedController] clear];
	[tableView reloadData];
}

- (void)windowBecameMain:(NSNotification*)notif
{
    NSWindow* w = [notif object];

    if([w isKindOfClass:[TimelineWindow class]]){
        [statusItemView setRead];
    }
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
    // TODO: some type checking for sender tag would be apropriate
    [statusMenu removeItemAtIndex:[sender tag]];
    [statusMenu insertItemWithTitle:@"Connecting..." action:nil keyEquivalent:@"" atIndex:[sender tag]];
    [[statusMenu itemAtIndex:[sender tag]] setTarget:self];
    [[statusMenu itemAtIndex:[sender tag]] setTag:[sender tag]];

    [[NSDistributedNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:N2N_CONNECT object:[[NSNumber numberWithInt:[sender tag]-1] stringValue]]];
}

- (IBAction)disconnect:(id)sender
{
    [statusMenu removeItemAtIndex:[sender tag]];
    [statusMenu insertItemWithTitle:@"Disconnecting..." action:nil keyEquivalent:@"" atIndex:[sender tag]];
    [[statusMenu itemAtIndex:[sender tag]] setTarget:self];
    [[statusMenu itemAtIndex:[sender tag]] setTag:[sender tag]];
    
    [[NSDistributedNotificationCenter defaultCenter]
     postNotification:[NSNotification notificationWithName:N2N_DISCONNECT object:[[NSNumber numberWithInt:[sender tag]-1] stringValue]]];
}

- (void) edgeConnected:(NSNotification *)notification
{
    statusItemView.vpn = YES;

    int i = [[notification object] intValue]+1;
    
    [statusMenu removeItemAtIndex:i];
    [statusMenu insertItemWithTitle:@"Disconnect VPN..." action:@selector(disconnect:) keyEquivalent:@"" atIndex:i];
    [[statusMenu itemAtIndex:i] setTarget:self];
    [[statusMenu itemAtIndex:i] setTag:i];
}

- (void) edgeDisconnected:(NSNotification *)notification
{
    statusItemView.vpn = NO;

    int i = [[notification object] intValue] + 1;
    
    [statusMenu removeItemAtIndex:i];
    [statusMenu insertItemWithTitle:@"Connect VPN..." action:@selector(connect:) keyEquivalent:@"" atIndex:i];
    [[statusMenu itemAtIndex:i] setTarget:self];
    [[statusMenu itemAtIndex:i] setTag:i];
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

- (void)postMessage:(id)sender
{
    [socket sendMessage:[postField string]];
    [postField setString:@""];
}

- (IBAction)showTimeline:(id)sender
{
    [timelineWindow toggle];
}

- (void)registerURLHandler
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSMutableString *url = [[[[event paramDescriptorForKeyword:keyDirectObject] stringValue] mutableCopy] autorelease];
    // now you can create an NSURL and grab the necessary parts
    [url replaceOccurrencesOfString:@"%20" withString:@" " options:0 range: NSMakeRange(0,[url length])];

    if([url hasPrefix:@"ganesh"]){
        [url replaceOccurrencesOfString:@"ganesh://" withString:@"" options:0 range: NSMakeRange(0,[url length])];
        if([url hasPrefix:@"direct/"]){
            [url replaceOccurrencesOfString:@"direct/" withString:@"@" options:0 range: NSMakeRange(0,[url length])];
            [timelineWindow makeFirstResponder:postField];
            [postField setString:@""];
            [postField insertText:url];
            [postField insertText:@" "];
        }
    }
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

// post field delegate
- (BOOL)textView:(NSTextView *)inTextView doCommandBySelector:(SEL)inSelector
{
    if (inSelector == @selector(insertTab:)){
        return YES;
    }
    else if (inSelector == @selector(insertNewline:)){
        [inputStack push:[inTextView string]];
        [self postMessage:nil];
        return YES;
    }
    // command history for later
    else if (inSelector == @selector(moveUp:)){
        NSString *controlString = [inputStack previous];
        if (controlString != nil){
            [inTextView setString:controlString];
        }
        return YES;
    }
    else if (inSelector == @selector(moveDown:)){
        NSString *controlString = [inputStack next];
        if (controlString != nil){
            [inTextView setString:controlString];
        }
        return YES;
    }

    return NO;
}

- (IBAction)getVpn:(id)sender
{
    [socket getVpn];
}

@end
