//
//  PreferenceController.h
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferenceController : NSObject {
	IBOutlet NSTextField * userLoginField;
	IBOutlet NSTextField * userPasswordField;
	IBOutlet NSTextField * serverAddressField;
	IBOutlet NSTextField * serverPortField;
}

- (IBAction)saveLoginAndPassword:(id)sender;
- (IBAction)saveServerAddressAndPort:(id)sender;

- (NSString *)username;
- (NSString *)password;
- (NSString *)serverAddress;
- (NSString *)serverUrl;


@end
