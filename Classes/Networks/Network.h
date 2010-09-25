//
//  Network.h
//  ganesh
//
//  Created by Reza Jelveh on 14.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Network : NSObject {
    NSString *supernode;
    NSString *community;
    NSString *key;
}

@property(retain)   NSString *supernode;
@property(retain)   NSString *community;
@property(retain)   NSString *key;

@end
