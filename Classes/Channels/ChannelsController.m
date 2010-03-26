//
//  ChannelsController.m
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "ChannelsController.h"
#import "NSString_truncate.h"
#import "AppController.h"

#import "Channel.h"

static ChannelsController *sharedChannelController = nil;

@implementation ChannelsController
@synthesize channels;

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

- (Channel*)createDefaultChannel
{
    Channel *defaultChannel = [[Channel alloc] init];
    defaultChannel.name = @"default channel";
    defaultChannel.description = @"this thing exists because something went wrong acquiring the channel list";
    defaultChannel.channel_id = [NSNumber numberWithInt:1];
    return defaultChannel;
}


- (id)init
{
    if (self = [super init]) {
        self.channels = [[NSMutableArray alloc] init];
        [self.channels addObject:[self createDefaultChannel]];
        selectedRow = 0;
    }

    return self;
}

- (void)addChannels:(id)obj
{
    NSArray *myChannels = [obj objectForKey:@"channels"];
    if (myChannels) {
        NSEnumerator *myArrayEnumerator = [myChannels objectEnumerator];
        NSDictionary *channelData;
        Channel *thisChannel;

        [self.channels removeAllObjects];
        while (channelData = [myArrayEnumerator nextObject])
        {
            thisChannel = [[Channel alloc] initWithData:channelData];
            if(thisChannel){
                [self.channels addObject:thisChannel];
            }
        }
    }

    [tableView reloadData];
}

- (id)selectedChannelId
{
    if([self.channels count]){
        Channel *channel = [self.channels objectAtIndex:selectedRow];

        return channel.channel_id;
    }
    return nil;
}

- (void)selectNextChannel
{
    if(++selectedRow == [channels count])
        selectedRow = 0;

    // set channel to the specified channel id
    [[AppController sharedController] setChannel:[self selectedChannelId]];

    [tableView reloadData];
}

- (void)selectPreviousChannel
{
    if(selectedRow-- <= 0)
        selectedRow = [channels count]-1;

    // set channel to the specified channel id
    [[AppController sharedController] setChannel:[self selectedChannelId]];

    [tableView reloadData];
}

// tableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [channels count];
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

    [aCell setAttributedTitle:[[[channels objectAtIndex:rowIndex] name] stringWithTruncatingToLength:13] active:isActive];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    selectedRow = rowIndex;
    [aTableView reloadData];
    // set channel to the specified channel id
    [[AppController sharedController] setChannel:[self selectedChannelId]];
    return NO;
}

@end
