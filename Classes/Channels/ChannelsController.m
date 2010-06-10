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
#import "RoundButtonCell.h"

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

/* TODO: rename */
- (void)incNewMessageCounterForChannel:(NSNumber*)channel_id {
    [self setNewMessageCounter:1 forChannel:channel_id];
}

- (void)setNewMessageCounter:(int)counter forChannel:(NSNumber*)channel_id{
    NSEnumerator *myArrayEnumerator = [self.channels objectEnumerator];
    Channel *thisChannel;
    int i=0;

    while (thisChannel = [myArrayEnumerator nextObject])
    {
        if([thisChannel.channel_id isEqualToNumber:channel_id]){
            if(counter != 0 && i != selectedRow){
                thisChannel.newCounter = thisChannel.newCounter + 1;
            }
            else{
                thisChannel.newCounter = 0;
            }
            [tableView reloadData];
            break;
        }
        i++;
    }
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
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(RoundButtonCell *)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    BOOL isActive = (rowIndex == selectedRow);
    if (isActive) {
        aCell.counter = 0;
        [[channels objectAtIndex:rowIndex] setNewCounter:0];
    }
    else {
        aCell.counter = [[channels objectAtIndex:rowIndex] newCounter];
    }

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
