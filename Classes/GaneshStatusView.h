//
//  GaneshStatusView.h
//  ganesh
//
//  Created by Reza Jelveh on 3/9/10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GaneshStatusView : NSImageView {
    NSStatusItem *statusItem;
    BOOL isMenuVisible;
    BOOL connected;
    BOOL newMessage;
    BOOL vpn;

    // images for status item states
    NSImage *statusNoVpnNoMessageImage;
    NSImage *statusNoVpnHasMessageImage;	
    NSImage *statusHasVpnNoMessageImage;
    NSImage *statusHasVpnHasMessageImage;
    // image for vpn status
    NSImage *keyImage;
}
@property (retain, nonatomic) NSStatusItem *statusItem;
@property (nonatomic, assign, getter=isConnected) BOOL connected;
@property (nonatomic, assign, getter=hasNewMessage) BOOL newMessage;
@property (nonatomic, assign, getter=hasVpn) BOOL vpn;

- (void) update;
- (void) setRead;
@end
