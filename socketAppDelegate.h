//
//  socketAppDelegate.h
//  socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//http://stackoverflow.com/questions/1496788/building-for-10-5-in-xcode-3-2-on-snow-leopard-error
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface socketAppDelegate : NSObject
#else
@interface socketAppDelegate : NSObject <NSApplicationDelegate>
#endif
{
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
