//
//  Channels.m
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "Channels.h"


@implementation Channels

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


// tableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 3;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (rowIndex == 0)
        return [NSNumber numberWithInt:NSOnState];
    return [NSNumber numberWithInt:NSOffState];
}

// tableView delegates
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    switch(rowIndex){
        case 0:
            [aCell setAttributedTitle:@"Default"];
            break;

        case 1:
            [aCell setAttributedTitle:@"Chuck Norris..."];
            break;

        case 2:
            [aCell setAttributedTitle:@"Biene Maja"];
            break;

    }
}


@end
