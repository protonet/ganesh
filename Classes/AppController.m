//
//  AppController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Acculogic GmbH. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void) awakeFromNib
{
    // create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];

    // allocate and load the images into the app
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];

    // set the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];

    // tells the nsstatusitem what menu to load
    [statusItem setMenu:statusMenu];
    // sets the tooltip for the item
    [statusItem setToolTip:@"Custom Menu Item"];
    // enable highlighting
    [statusItem setHighlightMode:YES];
}

- (void) dealloc
{
    // Release the 2 images
    [statusImage release];
    [statusHighlightImage release];
    [super dealloc];
}

@end
