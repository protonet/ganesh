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

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
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
    NSString *fullResPath = [resPath stringByAppendingPathComponent:@"n2n_helper.app"];
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

@end
