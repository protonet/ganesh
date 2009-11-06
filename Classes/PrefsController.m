//
//  PrefsController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import "PrefsController.h"

static PrefsController *sharedPrefsController = nil;

@implementation PrefsController

+ (PrefsController*)sharedController
{
    @synchronized(self) {
        if (sharedPrefsController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedPrefsController;

}

-(id) init {
    [super initWithWindowNibName:@"Preferences"];
    return self;
}

-(IBAction) showWindow:(id)sender
{
    [super showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
    [[self window] makeKeyAndOrderFront:self];
    [[self window] center];
    [[self window] setLevel:NSFloatingWindowLevel];
}

-(void) windowWillClose:(NSNotification *)aNotification {
    // [self saveToPreferences:self];
}

@end
