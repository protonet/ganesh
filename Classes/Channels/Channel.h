//
//  Channel.h
//  ganesh
//
//  Created by Reza Jelveh on 25.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Channel : NSObject {
    NSInteger channel_id;
	NSString  *name;
	NSString  *description;
}
@property(nonatomic, assign) NSInteger channel_id;
@property(retain)   NSString *name;
@property(retain)   NSString *description;

@end
