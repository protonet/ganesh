//
//  Tweet.h
//  socket
//
//  Created by jelveh on 10.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "TargetConditionals.h"

@interface Tweet : NSObject {
#if !(TARGET_OS_IPHONE)
	NSImage * userImage;
#endif
	NSString  * message;
	NSString  * author;
    NSNumber  * tweet_id;
    NSNumber  * channel_id;
    NSDate    * date;
    NSURL     * icon_url;
    BOOL      own;
    BOOL      response;
}

@property(retain)   NSString * message;
@property(retain)   NSString * author;
@property(retain)   NSDate   * date;
@property(retain)   NSURL    * icon_url;
#if !(TARGET_OS_IPHONE)
@property(assign) NSImage * userImage;
#endif
@property (nonatomic, assign, getter=isOwn) BOOL own;
@property (nonatomic, assign, getter=isResponse) BOOL response;
@property(retain) NSNumber *tweet_id;
@property(retain) NSNumber *channel_id;

- (id)initWithData:(NSMutableDictionary *)data;

@end
