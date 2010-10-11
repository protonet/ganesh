//
//  Network.m
//  ganesh
//
//  Created by Reza Jelveh on 14.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "NSString+SBJSON.h"

#import "Network.h"

@implementation Network
@synthesize description;
@synthesize supernode;
@synthesize community;
@synthesize key;

- (id)initWithJSON:(NSString *)message andDescription:(NSString *)description
{
    NSDictionary *network = [message JSONValue];

    if([network objectForKey:@"community"] != nil &&
       [network objectForKey:@"key"] != nil){

        if (self = [super init]) {
            self.description = description;
            self.supernode   = @"team.protonet.info:1099";
            self.community   = [network objectForKey:@"community"];
            self.key         = [network objectForKey:@"key"];
        }
        return self;
    }
    return nil;
}

- (id)initWithDictionary:(NSMutableDictionary *)network
{
    if (self = [super init]) {
        self.description = [network objectForKey:@"description"];
        self.supernode = [network objectForKey:@"supernode"];
        self.community = [network objectForKey:@"community"];
        self.key       = [network objectForKey:@"key"];
    }
    return self;
}

- (void)dealloc
{
    self.description = nil;
    self.supernode = nil;
    self.community = nil;
    self.key       = nil;
    [super dealloc];
}

@end
