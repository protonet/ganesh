//
//  TimelineWindow.m
//  ganesh
//
//  Created by Reza Jelveh on 10.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "TimelineWindow.h"


@implementation TimelineWindow

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"w"]) {
            [self performClose:self];
            return YES;
        }
    }
    return [super performKeyEquivalent:event];
}

- (void)fadeOut {
    [[self animator] setAlphaValue:0.0];
    isOpen = NO;
}

- (void)fadeIn {
    [NSApp activateIgnoringOtherApps:YES];
    [self makeKeyAndOrderFront:self];
    [[self animator] setAlphaValue:1.0];
    isOpen = YES;    
}

- (void)close {
    [self fadeOut];
}

- (void)toggle{
	//Fades in & out nicely
	if(isOpen) {
        [self fadeOut];
	}
	else {
        [self fadeIn];
    }
}

@end
