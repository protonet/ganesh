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
            [[self alloc] initWithWindowNibName:@"Preferences"]; // assignment not done here
        }
    }
    return sharedPrefsController;

}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedPrefsController == nil) {
            sharedPrefsController = [super allocWithZone:zone];
            return sharedPrefsController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
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
    return UINT_MAX;  //denotes an object that cannot be released
}


- (void)release
{
    //do nothing
}


- (id)autorelease

{
    return self;
}


-(IBAction) showWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    if (![[self window] isVisible])
        [[self window] center];
    [super showWindow:sender];

}

-(void) windowWillClose:(NSNotification *)aNotification {
    // [self saveToPreferences:self];
}

@end
