//
//  NetworksController.h
//  ganesh
//
//  Created by Reza Jelveh on 15.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NetworksDataSource;

@interface NetworksController : NSObject {
    IBOutlet NSWindow    *addNetworkSheet;
    IBOutlet NSWindow    *preferenceWindow;
    IBOutlet NSTextField *descriptionInput;
    IBOutlet NSTextField *supernodeInput;
    IBOutlet NSTextField *communityInput;
    IBOutlet NSTextField *keyInput;
    IBOutlet NSTableView *table;

    NetworksDataSource *dataSource;
}

@property(retain) NetworksDataSource *dataSource;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)closeSheetCancel:(id)sender;
- (IBAction)closeSheetOk:(id)sender;

@end
