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

- (IBAction)saveLoginAndPassword:(id)sender
{
	[userDefaults setObject:[userLoginField stringValue] forKey:@"username"];
	[userDefaults setObject:[userPasswordField stringValue] forKey:@"password"];
	
	NSLog(@"saving login & password");
}

- (IBAction)saveServerAddressAndPort:(id)sender
{
	[userDefaults setObject:[serverAddressField stringValue] forKey:@"serverAddress"];
	[userDefaults setObject:[serverPortField stringValue] forKey:@"serverPort"];
	NSString * htaccessUser = [serverHtaccessUserField stringValue];
	if ([htaccessUser isEqualToString:@""])
	{
		NSLog(@"removing htaccess settings");
		[userDefaults removeObjectForKey:@"serverHtaccessUser"];
		[userDefaults removeObjectForKey:@"serverHtaccessPassword"];
	} else {
		[userDefaults setObject:[serverHtaccessUserField stringValue] forKey:@"serverHtaccessUser"];
		[userDefaults setObject:[serverHtaccessPasswordField stringValue] forKey:@"serverHtaccessPassword"];
	}


	NSLog(@"saving server, port & HTACCESS data!");
}	

- (NSString *)username
{
	NSString *username = [userDefaults objectForKey:@"username"];
	return username;
}

- (NSString *)password
{
	NSString *password = [userDefaults objectForKey:@"password"];
	return password;
}

- (NSString *)serverAddress
{
	NSString *serverAddress = [userDefaults objectForKey:@"serverAddress"];
	return serverAddress;
}

- (NSString *)serverPort
{
	NSString *serverPort = [userDefaults objectForKey:@"serverPort"];
	return serverPort;
}

- (NSString *)serverHtaccessUser
{
	NSString * htaccessUser = [userDefaults objectForKey:@"serverHtaccessUser"];
	return htaccessUser;
}

- (NSString *)serverHtaccessPassword
{
	NSString * htaccessPassword = [userDefaults objectForKey:@"serverHtaccessPassword"];
	return htaccessPassword;
}

- (NSString *)serverUrl {
	NSString * htaccessString = nil;
	if ([self serverHtaccessUser]) {
		htaccessString = [NSString stringWithFormat:@"%@:%@@", [self serverHtaccessUser], [self serverHtaccessPassword]];
	} else {
		htaccessString = @"";
	}

	NSLog(@"%@", htaccessString);
	NSString *serverUrl = [NSString stringWithFormat:@"http://%@%@:%@", htaccessString, [self serverAddress], [self serverPort]];
	return serverUrl;
}
@end
