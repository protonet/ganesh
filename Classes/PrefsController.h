//
//  PrefsController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefsController : NSWindowController {
    IBOutlet NSWindow *window;
}

+ (PrefsController*)sharedController;

@end
