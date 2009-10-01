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
    NSTask *run;
    run=[[NSTask alloc] init];
    [run setLaunchPath: @"/usr/bin/open"];
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *fullResPath = [resPath stringByAppendingPathComponent:@"n2n.app"];
    NSArray *arguments = [NSArray arrayWithObjects: fullResPath, nil];
    [run setArguments: arguments];
    [run launch];
    [run release];
}

- (void) awakeFromNib
{

    // create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];

    [self checkAndCopyHelper:bundle];

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

    /* (C) ~/Library/Application Support/applicationSupportDirectory/PlugIns
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

- (void) checkAndCopyHelper:(NSBundle *)bundle
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *srcPath = [bundle pathForResource:@"n2n" ofType:@"app"];
    NSString *dstPath = [NSString stringWithFormat:@"%@/n2n.app", [self appSupportPath]];

    [fileManager createDirectoryAtPath:[self appSupportPath]
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];

    [fileManager copyItemAtPath:srcPath
                         toPath:dstPath
                          error:&error];

}

@end
