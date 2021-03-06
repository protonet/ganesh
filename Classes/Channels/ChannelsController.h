//
//  ChannelsController.h
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChannelsController : NSObject {
    IBOutlet NSTableView *tableView;

    @private NSMutableArray *channels;

    int selectedRow;
}

@property(readwrite, assign) NSMutableArray *channels;
+ (ChannelsController*)sharedController;


@end
