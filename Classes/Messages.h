//
//  Messages.h
//  socket
//
//  Created by Reza Jelveh on 12.02.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MAX_TWEETS 20

@interface Messages : NSObject {
    @private NSMutableArray *messages;
}

@property(readwrite, assign) NSMutableArray *messages;

+ (Messages*)sharedController;
- (void)addMessageToTweets:(NSString *)string;
- (id)first;
- (void)clear;
- (NSUInteger)count;

@end
