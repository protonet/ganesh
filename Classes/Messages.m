//
//  Mesagges.m
//  socket
//
//  Created by Reza Jelveh on 12.02.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "Messages.h"
#import "Tweet.h"
#import "JSON.h"


static Messages *sharedMessagesController = nil;

@implementation Messages
@synthesize messages;

+ (Messages*)sharedController
{
    if (sharedMessagesController == nil) {
        sharedMessagesController = [[super allocWithZone:NULL] init];
    }
    return sharedMessagesController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    if (self = [super init]) {
        self.messages = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)push:(Tweet *)message
{
    // keyvalueobserving added
    [self willChangeValueForKey:@"messages"];

    [messages insertObject:message atIndex:0];
    // show only the 5 most recent tweets
    if([messages count] > MAX_TWEETS){
        [messages removeLastObject];
    }

    [self didChangeValueForKey:@"messages"];
}

- (void)addMessageToTweets:(NSString *)string {
    SBJsonParser *parser = [[SBJsonParser alloc] init];

    Tweet * tweet = [[Tweet alloc] initWithData:[parser objectWithString:string]];

    if (tweet) {
        [self push:tweet];
    }

    [parser release];
}

- (id)first
{
    return [messages objectAtIndex:0];
}

- (void)clear
{
    [messages removeAllObjects];
}
@end
