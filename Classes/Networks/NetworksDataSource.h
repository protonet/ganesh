//
//  NetworksDataSource.h
//  ganesh
//
//  Created by Reza Jelveh on 07.09.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NetworksDataSource : NSObject {
    NSMutableArray *networks;
}

@property(retain)  NSMutableArray *networks;

@end
