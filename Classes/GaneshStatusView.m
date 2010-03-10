//
//  GaneshStatusView.m
//  ganesh
//
//  Created by Reza Jelveh on 3/9/10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "GaneshStatusView.h"
#import "AppController.h"


@implementation GaneshStatusView
@synthesize statusItem;
@synthesize connected;
@synthesize newMessage;

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle mainBundle];

        // allocate and load the images into the app
        statusNoVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive" ofType:@"png"]];
        statusNoVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive_message" ofType:@"png"]];	
        
        statusHasVpnNoMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active" ofType:@"png"]];
        statusHasVpnHasMessageImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active_message" ofType:@"png"]];
        
        [super setImage: statusNoVpnNoMessageImage];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Draw status bar background, highlighted if clicked
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isMenuVisible];
    
    [super drawRect:rect];
}

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
    [menu setDelegate:nil];    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
    [[AppController sharedController] showTimeline:nil];
}

- (void)mouseUp:(NSEvent *)event
{
    isMenuVisible = NO;
    [self setNeedsDisplay:YES];    
}

- (void)rightMouseDown:(NSEvent *)event {
    [[self menu] setDelegate:self];
    [statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

- (void)setRead
{
    if(self.hasNewMessage){
        self.newMessage = NO;
        [self update];
    }
}

- (void)setConnected {
    if(self.hasNewMessage){
        [self setImage:statusHasVpnHasMessageImage];
    }
    else {
        [self setImage:statusHasVpnNoMessageImage];        
    }
}

- (void)setDisconnected {
    if(self.hasNewMessage){
        [self setImage:statusNoVpnHasMessageImage];
    }
    else {
        [self setImage:statusNoVpnNoMessageImage];
    }
}

- (void)update {
    if(self.connected){
        [self setConnected];
    }
    else {
        [self setDisconnected];
    }

}

@end
