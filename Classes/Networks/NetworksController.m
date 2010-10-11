//
//  NetworksController.m
//  ganesh
//
//  Created by Reza Jelveh on 15.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "NetworksController.h"
#import "NetworksDataSource.h"
#import "Network.h"
#import "PrefsController.h"

@implementation NetworksController
@synthesize dataSource;

- (id)init
{
    if(self = [super init]){
        self.dataSource = [[[NetworksDataSource alloc] init] autorelease];

    }
    return self;
}

- (void)awakeFromNib
{
    [table setDelegate:self];
    [table setDataSource:self.dataSource];
}

- (void)dealloc
{
    self.dataSource = nil;
    [super dealloc];
}

- (void)add:(id)sender
{
    [NSApp beginSheet: addNetworkSheet
       modalForWindow: [[PrefsController sharedController] window]
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (void)remove:(id)sender
{
    if ([table selectedRow] < 0 || [table selectedRow] >= [[self.dataSource networks] count])
        return;
    [self.dataSource removeNetwork:[table selectedRow]];
    [table reloadData];
}

- (void)closeSheetOk:(id)sender
{
    [NSApp endSheet:addNetworkSheet returnCode: NSAlertDefaultReturn];
}

- (void)closeSheetCancel:(id)sender
{
    [NSApp endSheet:addNetworkSheet];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
        NSString *description;
        NSString *supernode;
        NSString *community;
        NSString *key;
        Network  *network;

        description = [descriptionInput stringValue];
        supernode = [supernodeInput stringValue];
        community = [communityInput stringValue];
        key       = [keyInput stringValue];
        if([description length] > 0 && [supernode length] > 0 && [community length] > 0 && [key length] > 0){
            network = [[Network alloc] init];
            network.description = description;
            network.supernode = supernode;
            network.community = community;
            network.key       = key;

            [self.dataSource addNetwork:network];
            [table reloadData];
        }

    }

    [sheet orderOut:self];
}
@end
