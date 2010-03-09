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
	NSString  * author;
    NSDate    * date;
    NSURL     * icon_url;
}

@property(readwrite, copy)   NSString * message;
@property(readwrite, copy)   NSString * author;
@property(readwrite, copy)   NSDate   * date;
@property(readwrite, copy)   NSURL    * icon_url;
@property(readwrite, assign) NSImage * userImage;

- (id)initWithData:(NSMutableDictionary *)data;

@end
