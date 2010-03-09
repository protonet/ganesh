//
//  Tweet.m
//  socket
//
//  Created by jelveh on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet
@synthesize author;
@synthesize date;
@synthesize icon_url;
@synthesize message;
@synthesize userImage;

- (id)initWithData:(NSMutableDictionary *)data
{
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverUrl"];

	self.message = [data objectForKey:@"message"];

    if (message && (self = [super init])) {
        self.date = [NSDate date];
        self.author = [data objectForKey:@"author"];
		NSString * profileUrlString = [NSString stringWithFormat:@"http://%@%@", serverUrl, [data objectForKey:@"user_icon_url"]];
        self.icon_url = [NSURL URLWithString:profileUrlString];
		userImage = [[[NSImage alloc] init] initWithContentsOfURL:icon_url];
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
