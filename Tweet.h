//
//  Tweet.h
//  socket
//
//  Created by jelveh on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Tweet : NSObject {
	NSImage * userImage;
	NSString  * message;

}

@property(readwrite, assign) NSString * message;
@property(readwrite, assign) NSImage * userImage;

- (id)initWithData:(NSMutableDictionary *)data;

@end