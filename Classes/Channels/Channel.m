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
@synthesize name;
@synthesize description;

- (id)initWithData:(NSMutableDictionary *)data
{
    if ([data objectForKey:@"id"] && (self = [super init])) {
        self.channel_id  = [data objectForKey:@"id"];
        self.name        = [data objectForKey:@"name"];
        self.description = [data objectForKey:@"description"];
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
