//
//  PreferenceWindow.m
//  ganesh
//
//  Created by Reza Jelveh on 06.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferenceWindow.h"


@implementation PreferenceWindow

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"w"]) {
            [self performClose:self];
            return YES;
        }
    }
    return [super performKeyEquivalent:event];
}

- (void)resignMainWindow {
    // automatically close the preference window when inactive
    [self performClose:self];
    [super resignMainWindow];
}
@end
