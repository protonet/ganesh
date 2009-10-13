//
//  AppController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import "AppController.h"
#import <SecurityFoundation/SFAuthorization.h>

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

@implementation AppController

- (IBAction)connect:(id)sender {
    [[NSDistributedNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:@"N2NEdgeConnect" object:nil]];
}

- (void) disconnect
{
}

/**
 * run n2n.app from resources
 */
- (void)runApp{
    n2nApp = [[NSTask alloc] init];
    // [run setLaunchPath: @"/usr/bin/open"];
    NSString *n2nPath = [NSString stringWithFormat:@"%@/n2n.app/Contents/MacOS/n2n", [self appSupportPath]];
    [n2nApp setLaunchPath:n2nPath];
    NSArray *arguments = [NSArray arrayWithObjects: n2nPath, nil];
    [n2nApp setArguments: arguments];
    [n2nApp launch];
}

- (void) awakeFromNib
{

    // create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];

    [self checkAndCopyHelper];

    // allocate and load the images into the app
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active" ofType:@"png"]];

    // set the images in our NSStatusItem
    [statusItem setImage:statusImage];
    // [statusItem setAlternateImage:statusHighlightImage];

    // tells the nsstatusitem what menu to load
    [statusItem setMenu:statusMenu];
    // sets the tooltip for the item
    [statusItem setToolTip:@"Custom Menu Item"];
    // enable highlighting
    [statusItem setHighlightMode:YES];

    [self runApp];
}

- (void) dealloc
{
    // Release the 2 images
    [statusImage release];
    [statusHighlightImage release];
    [super dealloc];
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

- (void) checkAndCopyHelper
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"n2n" ofType:@"app"];
    NSString *dstPath = [NSString stringWithFormat:@"%@/n2n.app", [self appSupportPath]];


    [fileManager createDirectoryAtPath:[self appSupportPath]
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];

    [self copyPathWithforcedAuthentication:srcPath toPath:dstPath error:&error];

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
            { "-R", srcPath, dstPath, NULL },  // cp
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

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"app will terminate");
    [n2nApp terminate];
    [n2nApp release];
}

@end
