//
//  PreferenceController.m
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

@implementation PreferenceController

- (id) init
{
	[super init];
	userDefaults = [NSUserDefaults standardUserDefaults];
	return self;
}

- (IBAction)saveLoginAndPassword:(id)sender {
	[userDefaults setObject:[userLoginField stringValue] forKey:@"username"];
	[userDefaults setObject:[userPasswordField stringValue] forKey:@"password"];
	
	NSLog(@"saving login & password");
}

- (IBAction)saveServerAddressAndPort:(id)sender {
	[userDefaults setObject:[serverAddressField stringValue] forKey:@"serverAddress"];
	[userDefaults setObject:[serverPortField stringValue] forKey:@"serverPort"];

	NSLog(@"saving server & port");
}	

- (NSString *)username {
	NSString *username = [userDefaults objectForKey:@"username"];
	return username;
}

- (NSString *)password {
	NSString *password = [userDefaults objectForKey:@"password"];
	return password;
}

- (NSString *)serverAddress {
	NSString *serverAddress = [userDefaults objectForKey:@"serverAddress"];
	return serverAddress;
}

- (NSString *)serverPort {
	NSString *serverPort = [userDefaults objectForKey:@"serverPort"];
	return serverPort;
}

- (NSString *)serverUrl {
	NSString *serverUrl = [NSString stringWithFormat:@"http://%@:%@", [userDefaults objectForKey:@"serverAddress"], [userDefaults objectForKey:@"serverPort"]];
	return serverUrl;
}
@end
