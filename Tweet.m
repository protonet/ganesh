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
	message = [data objectForKey:@"message"];

    if (message && self = [super init]) {
		NSString * profileUrlString = [NSString stringWithFormat:@"http://localhost:3000%@", [data objectForKey:@"user_icon_url"]];
		NSURL *profileUrl = [NSURL URLWithString:profileUrlString];
		userImage = [[[NSImage alloc] init] initWithContentsOfURL:profileUrl];
        return self;
    }
    else{
        return nil;
    }
}

- (void)dealloc
{
    [userImage release];
    [super dealloc];
}
@end
