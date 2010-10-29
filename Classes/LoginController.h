//
//  LoginController.h
//  ganesh
//
//  Created by Reza Jelveh on 29.10.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginController : NSObject {
    IBOutlet NSWindow *loginWindow;
    IBOutlet NSWindow *nodeFoundWindow;
}

- (IBAction) cancel:(id)sender;
- (IBAction) setNodeSettings:(id)sender;
- (IBAction) setLoginSettings:(id)sender;

@end
