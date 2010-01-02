//
//  PreferenceController.m
//  socket
//
//  Created by jelveh on 29.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

@implementation PreferenceController

+ (void)initialize
{
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
    // Put defaults in the dictionary
    [defaultValues setObject:@"dudemeister" forKey:@"Username"];
    [defaultValues setObject:@"geheim" forKey:@"Password"];
	[defaultValues setObject:@"localhost" forKey:@"ServerAddress"];
    [defaultValues setObject:@"3000" forKey:@"ServerPort"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Register the dictionary of defaults
    [defaults registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}

- (IBAction)saveLoginAndPassword:(id)sender {
	[defaults setObject:userLoginField forKey:@"Username"];
	[defaults setObject:userPasswordField forKey:@"Password"];
}

- (IBAction)saveServerAddressAndPort:(id)sender {
	[defaults setObject:serverAddressField forKey:@"ServerAddress"];
	[defaults setObject:serverPortField forKey:@"ServerPort"];	
}	

- (NSString *)username {
	NSString *username = [defaults objectForKey:@"Username"];
	return username;
}

- (NSString *)password {
	NSString *password = [defaults objectForKey:@"Password"];
	return password;
}

- (NSString *)serverAddress {
	NSString *serverAddress = [defaults objectForKey:@"ServerAddress"];
	return serverAddress;
}

- (NSString *)serverUrl {
	NSString *serverUrl = [NSString stringWithFormat:@"http://%@:%@", [defaults objectForKey:@"ServerAddress"], [defaults objectForKey:@"ServerPort"]];
	return serverUrl;
}
@end
