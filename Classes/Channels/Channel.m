//
//  Channel.m
//  ganesh
//
//  Created by Reza Jelveh on 25.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "Channel.h"


@implementation Channel
@synthesize channelId;
@synthesize name;
@synthesize description;

- (id)initWithData:(NSMutableDictionary *)data
{
    if ([data objectForKey:@"message"] && (self = [super init])) {
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
