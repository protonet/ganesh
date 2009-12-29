//
//  PreferenceController.m
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

NSString * const PTNUsernameKey  = @"Username";
NSString * const PTNPasswordKey	 = @"Password";
NSString * const PTNServerAddressKey = @"ServerAddress";
NSString * const PTNServerPortKey    = @"ServerPort";

@implementation PreferenceController

+ (void)initialize
{
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
    // Put defaults in the dictionary
    [defaultValues setObject:@"dudemeister" forKey:PTNUsernameKey];
    [defaultValues setObject:@"geheim" forKey:PTNPasswordKey];
	[defaultValues setObject:@"localhost" forKey:PTNServerAddressKey];
    [defaultValues setObject:@"3000" forKey:PTNServerPortKey];
	
	
    // Register the dictionary of defaults
    [[NSUserDefaults standardUserDefaults]
	 registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}

- (IBAction)saveLoginAndPassword:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:userLoginField forKey:PTNUsernameKey];
	[defaults setObject:userPasswordField forKey:PTNPasswordKey];
}

- (IBAction)saveServerAddressAndPort:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:serverAddressField forKey:PTNServerAddressKey];
	[defaults setObject:serverPortField forKey:PTNServerPortKey];	
}	

- (NSString *)username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults objectForKey:PTNUsernameKey];
	return username;
}

- (NSString *)password {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *password = [defaults objectForKey:PTNPasswordKey];
	return password;
}

- (NSString *)serverAddress {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *serverAddress = [defaults objectForKey:PTNServerAddressKey];
	return serverAddress;
}

- (NSString *)serverUrl {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *serverUrl = [NSString stringWithFormat:@"http://%@:%@", [defaults objectForKey:PTNServerAddressKey], [defaults objectForKey:PTNServerPortKey]];
	return serverUrl;
}
@end
