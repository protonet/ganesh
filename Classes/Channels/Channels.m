//
//  Channels.m
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "Channels.h"
#import "NSString_truncate.h"

@implementation Channels

- (void)awakeFromNib
{
    selectedRow = 0;
}

// tableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 3;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (rowIndex == selectedRow)
        return [NSNumber numberWithInt:NSOnState];
    return [NSNumber numberWithInt:NSOffState];
}

// tableView delegates
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    BOOL isActive = (rowIndex == selectedRow);

    switch(rowIndex){
        case 0:
            [aCell setAttributedTitle:[@"Default" stringWithTruncatingToLength:13] active:isActive];
            break;

        case 1:
            [aCell setAttributedTitle:[@"Chuck Norris aotuahs oeuh sh" stringWithTruncatingToLength:13] active:isActive];
            break;

        case 2:
            [aCell setAttributedTitle:[@"homebase blablabla" stringWithTruncatingToLength:13] active:isActive];
            break;

    }
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    selectedRow = rowIndex;
    [aTableView reloadData];
    return NO;
}

@end
