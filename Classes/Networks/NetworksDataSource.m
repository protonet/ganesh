//
//  NetworksDataSource.m
//  ganesh
//
//  Created by Reza Jelveh on 07.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "N2NUserDefaultsController.h"
#import "NetworksDataSource.h"
#import "Network.h"


@implementation NetworksDataSource
@synthesize networks;

- (id)init
{
    if(self = [super init]){
        NSArray *nets = [[N2NUserDefaultsController standardUserDefaults] arrayForKey:@"networks"];
        if (nets){
            self.networks = [nets mutableCopy];
        }
        else{
            self.networks = [NSMutableArray array];
        }
    }
    return self;
}

- (void)dealloc
{
    self.networks = nil;
    [super dealloc];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.networks count];
}

- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
                            row:(int)row
{
    NSDictionary *network = [self.networks objectAtIndex:row];
    if([[tableColumn identifier] isEqualToString:@"description"]){
        return [network objectForKey:@"description"];
    }
    else if([[tableColumn identifier] isEqualToString:@"supernode"]){
        return [network objectForKey:@"supernode"];
    }
    else if([[tableColumn identifier] isEqualToString:@"community"]){
        return [network objectForKey:@"community"];
    }
    else{
        return [network objectForKey:@"key"];
    }
}

- (void)addNetwork:(Network *)network
{
    NSDictionary *networkDictionary = [NSDictionary dictionaryWithObjectsAndKeys:network.description, @"description",
                 network.supernode, @"supernode",
                 network.community, @"community",
                 network.key, @"key", nil];

    [self.networks addObject:networkDictionary];
    [[N2NUserDefaultsController standardUserDefaults] setObject:self.networks
                                                         forKey:@"networks"];
}

- (void)removeNetwork:(unsigned int)networkId
{
    [self.networks removeObjectAtIndex:networkId];
    [[N2NUserDefaultsController standardUserDefaults] setObject:self.networks
                                                         forKey:@"networks"];
}

- (void)clearNetworks
{
    self.networks = [NSMutableArray array];
    [[N2NUserDefaultsController standardUserDefaults] removeObjectForKey:@"networks"];
}

@end
