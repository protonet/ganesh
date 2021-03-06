//
//  TimelineWindow.m
//  ganesh
//
//  Created by Reza Jelveh on 10.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "TimelineWindow.h"
#import "ChannelsController.h"

@implementation TimelineWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)styleMask
                  backing:(NSBackingStoreType)backingType
                    defer:(BOOL)flag
{
    if(self = [super initWithContentRect:contentRect styleMask:styleMask backing:backingType defer:flag]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        isFloating               = [defaults boolForKey:@"enableFloating"];
        [self shouldFloat:isFloating];

        [defaults addObserver:self forKeyPath:@"enableFloating" options:0 context:0];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"enableFloating"]){
        isFloating = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableFloating"];
        [self shouldFloat:isFloating];
    }
}

- (void)resignMainWindow
{
    if (!isFloating) {
        [self performClose:self];
    }
    [super resignMainWindow];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"w"]) {
            [self performClose:self];
            return YES;
        }
    }
    else if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSControlKeyMask) {
        if ([[event charactersIgnoringModifiers] isEqualToString:@"n"]) {
            [[ChannelsController sharedController] selectNextChannel];
            return YES;
        }
        else if ([[event charactersIgnoringModifiers] isEqualToString:@"p"]) {
            [[ChannelsController sharedController] selectPreviousChannel];
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

- (void)shouldFloat:(BOOL)enableFloating
{
    if(enableFloating){
        [self setLevel:NSFloatingWindowLevel];
    }
    else {
        [self setLevel:NSNormalWindowLevel];
    }
}
@end
