//
//  PreferenceController.h
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferenceController : NSObject {
	
	NSUserDefaults * userDefaults;
	
	NSString * username;
	NSString * password;
	NSString * serverAddress;
	NSString * serverPort;
	NSString * serverHtaccessUser;
	NSString * serverHtaccessPassword;

	IBOutlet NSTextField * userLoginField;
	IBOutlet NSSecureTextField * userPasswordField;
	IBOutlet NSTextField * serverAddressField;
	IBOutlet NSTextField * serverPortField;
	IBOutlet NSTextField * serverHtaccessUserField;
	IBOutlet NSSecureTextField * serverHtaccessPasswordField;
	
	NSKeyValueObservingOptions optionsForObserver;
	void * contextForObserver;

}

@property(readwrite, assign) NSString * username;
@property(readwrite, assign) NSString * password;
@property(readwrite, assign) NSString * serverAddress;
@property(readwrite, assign) NSString * serverPort;
@property(readwrite, assign) NSString * serverHtaccessUser;
@property(readwrite, assign) NSString * serverHtaccessPassword;

- (NSString *)serverUrl;

@end
