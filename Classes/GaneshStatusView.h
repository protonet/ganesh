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
    BOOL newMessage;

    // images for status item states
    NSImage *statusNoVpnNoMessageImage;
    NSImage *statusNoVpnHasMessageImage;	
    NSImage *statusHasVpnNoMessageImage;
    NSImage *statusHasVpnHasMessageImage;
}
@property (retain, nonatomic) NSStatusItem *statusItem;
@property (nonatomic, assign, getter=hasNewMessage) BOOL newMessage;

@end
