//
//  ChannelsController.m
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "ChannelsController.h"
#import "NSString_truncate.h"

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

- (id)init
{
    if (self = [super init]) {
        self.channels = [[NSMutableArray alloc] init];
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


- (void)awakeFromNib
{
    selectedRow = 0;
}

- (void)selectNextChannel
{
    if(++selectedRow == [channels count])
        selectedRow = 0;
    [tableView reloadData];
}

- (void)selectPreviousChannel
{
    if(selectedRow-- <= 0)
        selectedRow = [channels count]-1;
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

    [aCell setAttributedTitle:[[[channels objectAtIndex:rowIndex] description] stringWithTruncatingToLength:13] active:isActive];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    selectedRow = rowIndex;
    [aTableView reloadData];
    return NO;
}

@end
