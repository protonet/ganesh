//
//  Channel.m
//  ganesh
//
//  Created by Reza Jelveh on 25.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "Channel.h"


@implementation Channel
@synthesize channel_id;
@synthesize uuid;
@synthesize name;
@synthesize description;
@synthesize newCounter;

- (id)initWithData:(NSMutableDictionary *)data
{
    if ([data objectForKey:@"id"] && (self = [super init])) {
        self.channel_id  = [data objectForKey:@"id"];
        self.uuid        = [data objectForKey:@"uuid"];
        self.name        = [data objectForKey:@"name"];
        self.description = [data objectForKey:@"description"];
        self.newCounter  = 0;
        return self;
    }
    else{
        return nil;
    }
}

- (void)dealloc
{
    self.name        = nil;
    self.description = nil;
    [super dealloc];
}

@end
