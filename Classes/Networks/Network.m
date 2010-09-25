//
//  Network.m
//  ganesh
//
//  Created by Reza Jelveh on 14.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "Network.h"

@implementation Network
@synthesize supernode;
@synthesize community;
@synthesize key;

- (id)initWithDictionary:(NSMutableDictionary *)network
{
    if (self = [super init]) {
        self.supernode = [network objectForKey:@"supernode"];
        self.community = [network objectForKey:@"community"];
        self.key       = [network objectForKey:@"key"];
    }
    return self;
}

- (void)dealloc
{
    self.supernode = nil;
    self.community = nil;
    self.key       = nil;
    [super dealloc];
}

@end
