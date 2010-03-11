//
//  PrefsController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import "PrefsController.h"
#import "PreferenceWindow.h"
#import "EMKeychainItem.h"

#define WINDOW_TITLE_HEIGHT 78

static NSString *GeneralToolbarItemIdentifier  = @"General";
static NSString *NetworkToolbarItemIdentifier  = @"Network";
static NSString *AdvancedToolbarItemIdentifier  = @"Advanced";

static PrefsController *sharedPrefsController = nil;

@implementation PrefsController

+ (PrefsController *)sharedController
{
	if (!sharedPrefsController) {
		sharedPrefsController = [[PrefsController alloc] initWithWindowNibName:@"Preferences"];
	}
	return sharedPrefsController;
}

- (void)dealloc
{
    sharedPrefsController = nil;
	[super dealloc];
}


-(IBAction) showWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    if (![[self window] isVisible])
        [[self window] center];
    [super showWindow:sender];

}

-(void) windowDidBecomeMain:(NSNotification *)aNotification {
//    EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"ganesh"
//                                                                                  withUsername:[userField stringValue]];
}

-(void) windowWillClose:(NSNotification *)aNotification {
//    [EMGenericKeychainItem addGenericKeychainItemForService:@"ganesh"
//                                               withUsername:[userField stringValue]
//                                                   password:[passField stringValue]];

}

-(void) windowDidResignMain:(NSNotification *)aNotification {
    [[self window] performClose:self];
}

- (void)awakeFromNib
{
	id toolbar = [[[NSToolbar alloc] initWithIdentifier:@"preferences toolbar"] autorelease];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration:NO];
	[toolbar setSizeMode:NSToolbarSizeModeDefault];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setDelegate:self];
	[toolbar setSelectedItemIdentifier:GeneralToolbarItemIdentifier];
	[[self window] setToolbar:toolbar];

	[self setActiveView:generalPreferenceView animate:NO];
	[[self window] setTitle:GeneralToolbarItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		AdvancedToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		AdvancedToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:
		GeneralToolbarItemIdentifier,
		NetworkToolbarItemIdentifier,
		AdvancedToolbarItemIdentifier,
		nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	if ([identifier isEqualToString:GeneralToolbarItemIdentifier]) {
		[item setLabel:GeneralToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"general"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:NetworkToolbarItemIdentifier]) {
		[item setLabel:NetworkToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"network"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else if ([identifier isEqualToString:AdvancedToolbarItemIdentifier]) {
		[item setLabel:AdvancedToolbarItemIdentifier];
		[item setImage:[NSImage imageNamed:@"advanced"]];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
	} else
		item = nil;
	return item; 
}

- (void)toggleActivePreferenceView:(id)sender
{
	NSView *view;

	if ([[sender itemIdentifier] isEqualToString:GeneralToolbarItemIdentifier])
		view = generalPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:NetworkToolbarItemIdentifier])
		view = networkPreferenceView;
	else if ([[sender itemIdentifier] isEqualToString:AdvancedToolbarItemIdentifier])
		view = advancedPreferenceView;

	[self setActiveView:view animate:YES];
	[[self window] setTitle:[sender itemIdentifier]];
}

- (void)setActiveView:(NSView *)view animate:(BOOL)flag
{
	// set the new frame and animate the change
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([[self window] frame]) - ([view frame].size.height + WINDOW_TITLE_HEIGHT);

	if ([[activeContentView subviews] count] != 0)
		[[[activeContentView subviews] objectAtIndex:0] removeFromSuperview];
	[[self window] setFrame:windowFrame display:YES animate:flag];

	[activeContentView setFrame:[view frame]];
	[activeContentView addSubview:view];
}

@end
