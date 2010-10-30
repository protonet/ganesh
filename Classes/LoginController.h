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
    IBOutlet NSTextField *loginField;
    IBOutlet NSTextField *passwordField;

    NSString *hostName;
}

@property(copy) NSString *hostName;

- (void) showNodeFoundWindow:(NSString *)hostName;
- (void) showLoginWindow;

- (IBAction) cancel:(id)sender;
- (IBAction) setNodeSettings:(id)sender;
- (IBAction) setLoginSettings:(id)sender;

@end
