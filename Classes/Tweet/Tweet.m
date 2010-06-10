//
//  Tweet.m
//  socket
//
//  Created by jelveh on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"
#import "GTMNSString+HTML.h"
#import "ChannelsController.h"

#import "Debug.h"

@implementation Tweet
@synthesize author;
@synthesize date;
@synthesize icon_url;
@synthesize own;
@synthesize response;
@synthesize message;
@synthesize userImage;
@synthesize tweet_id;
@synthesize channel_id;

- (id)initWithData:(NSMutableDictionary *)data
{
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverUrl"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];

    if ([data objectForKey:@"message"] && (self = [super init])) {
        self.message  = [[data objectForKey:@"message"] gtm_stringByEscapingForHTML];
        self.date     = [NSDate date];
        self.author   = [data objectForKey:@"author"];
        self.own      = [userName isEqualToString:self.author];
        self.tweet_id = [data objectForKey:@"id"];
        self.channel_id = [data objectForKey:@"channel_id"];
        [[ChannelsController sharedController] incNewMessageCounterForChannel:self.channel_id];

        NSRange range = [self.message rangeOfString:[NSString stringWithFormat:@"@%@", userName]];

        if (range.location != NSNotFound) {
            self.response = YES;
        }
        else {
            self.response = NO;
        }

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
    self.message  = nil;
    self.date     = nil;
    self.author   = nil;
    self.icon_url = nil;
    [userImage release];
    [super dealloc];
}
@end
