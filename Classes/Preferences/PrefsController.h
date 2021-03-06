//
//  PrefsController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SRRecorderControl.h>

@interface PrefsController : NSWindowController {
    IBOutlet NSWindow *window;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *networkPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
    IBOutlet NSTextField *userField;
    IBOutlet NSTextField *passField;
    IBOutlet SRRecorderControl *shortcutControl;
	
	IBOutlet NSView *activeContentView;
}

+ (PrefsController*)sharedController;

- (void)toggleActivePreferenceView:(id)sender;
- (void)setActiveView:(NSView *)view animate:(BOOL)flag;

@end
