//
//  ChannelsController.m
//  ganesh
//
//  Created by Reza Jelveh on 01.08.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "ChannelsController.h"


static ChannelsController *sharedChannelController = nil;

@implementation ChannelsController

+ (ChannelsController*)sharedController
{
    if (sharedChannelController == nil) {
        sharedChannelController = [[super allocWithZone:NULL] init];
    }
    return sharedChannelController;
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


- (void)addChannels:(id)test
{
}

- (void)incNewMessageCounterForChannel:(id)test
{
}

@end
