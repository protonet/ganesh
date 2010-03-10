//
//  TimelineWindow.h
//  ganesh
//
//  Created by Reza Jelveh on 10.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimelineWindow : NSWindow {
    BOOL isOpen;
}

- (void)toggle;

@end
