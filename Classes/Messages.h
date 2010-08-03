//
//  Messages.h
//  socket
//
//  Created by Reza Jelveh on 12.02.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//
#include "TargetConditionals.h"

#define MAX_TWEETS 30

#if !(TARGET_OS_IPHONE)
@interface Messages : NSObject {
#else
#include "AudioToolbox/AudioToolbox.h"

@interface Messages : TTModel {
#endif
    @private NSMutableArray *messages;
}

@property(readwrite, assign) NSMutableArray *messages;

+ (Messages*)sharedController;
- (void)addMessageToTweets:(NSString *)string;
- (id)first;
- (void)clear;
- (NSUInteger)count;

@end
