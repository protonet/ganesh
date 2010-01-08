//
//  PreferenceController.m
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

@implementation PreferenceController
@synthesize username;
@synthesize password;
@synthesize serverAddress;
@synthesize serverPort;
@synthesize serverHtaccessUser;
@synthesize serverHtaccessPassword;

- (id) init
{
	[super init];
	userDefaults = [NSUserDefaults standardUserDefaults];
	username = [userDefaults objectForKey:@"username"];
	password = [userDefaults objectForKey:@"password"];
	serverAddress = [userDefaults objectForKey:@"serverAddress"];
	serverPort = [userDefaults objectForKey:@"serverPort"];
	serverHtaccessUser = [userDefaults objectForKey:@"serverHtaccessUser"];
	serverHtaccessPassword = [userDefaults objectForKey:@"serverHtaccessPassword"];
		
	[self addObserver:self forKeyPath:@"username" options:optionsForObserver context:contextForObserver];
	[self addObserver:self forKeyPath:@"password" options:optionsForObserver context:contextForObserver];
	[self addObserver:self forKeyPath:@"serverAddress" options:optionsForObserver context:contextForObserver];
	[self addObserver:self forKeyPath:@"serverPort" options:optionsForObserver context:contextForObserver];
	[self addObserver:self forKeyPath:@"serverHtaccessUser" options:optionsForObserver context:contextForObserver];
	[self addObserver:self forKeyPath:@"serverHtaccessPassword" options:optionsForObserver context:contextForObserver];
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[userDefaults setObject:[userLoginField stringValue] forKey:@"username"];
	[userDefaults setObject:[userPasswordField stringValue] forKey:@"password"];
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
