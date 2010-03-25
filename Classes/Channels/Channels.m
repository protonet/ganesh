//
//  Channels.m
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "Channels.h"
#import "NSString_truncate.h"

static Channels *sharedChannelController = nil;

@implementation Channels
@synthesize channels;

+ (Channels*)sharedController
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

- (id)init
{
    if (self = [super init]) {
        self.channels = [[NSMutableArray alloc] init];
    }

    return self;
}


- (void)awakeFromNib
{
    selectedRow = 0;
}

- (void)selectNextChannel
{
    if(++selectedRow == 3)
        selectedRow = 0;
    [tableView reloadData];
}

- (void)selectPreviousChannel
{
    if(selectedRow-- <= 0)
        selectedRow = 3-1;
    [tableView reloadData];
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
