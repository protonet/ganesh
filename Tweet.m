//
//  Tweet.m
//  socket
//
//  Created by jelveh on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet
@synthesize message;
@synthesize userImage;

- (id)initWithData:(NSMutableDictionary *)data
{
    [super init];
	
//    NSLog(@"Tweet init");
//	[self setMessage:[data objectForKey:@"message"]];
	message = [data objectForKey:@"message"];

	if (!message) {
		return nil;
	}
	else
	{
		NSString * profileUrlString = [NSString stringWithFormat:@"http://localhost:3000%@", [data objectForKey:@"user_icon_url"]];
		NSURL *profileUrl = [NSURL URLWithString:profileUrlString];
		userImage = [[[NSImage alloc] init] initWithContentsOfURL:profileUrl];
		return self;
	}	
}
@end
