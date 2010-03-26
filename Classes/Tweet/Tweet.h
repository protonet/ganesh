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
    NSInteger tweet_id;
    NSInteger channel_id;
    NSDate    * date;
    NSURL     * icon_url;
    BOOL      own;
    BOOL      response;
}

@property(retain)   NSString * message;
@property(retain)   NSString * author;
@property(retain)   NSDate   * date;
@property(retain)   NSURL    * icon_url;
@property(assign) NSImage * userImage;
@property (nonatomic, assign, getter=isOwn) BOOL own;
@property (nonatomic, assign, getter=isResponse) BOOL response;
@property(nonatomic, assign) NSInteger tweet_id;
@property(nonatomic, assign) NSInteger channel_id;

- (id)initWithData:(NSMutableDictionary *)data;

@end
