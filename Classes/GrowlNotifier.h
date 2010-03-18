//
//  GrowlNotifier.h
//  ganesh
//
//  Created by Reza Jelveh on 2010-02-14
//  Copyright 2010 Protonet.info. All rights reserved.
//
#import <Growl/Growl.h>
#import <Cocoa/Cocoa.h>

@interface GrowlNotifier: NSObject <GrowlApplicationBridgeDelegate> {
    BOOL enableGrowl;
    BOOL onlyGrowlOnResponse;
}

+ (GrowlNotifier*)sharedController;
- (void)showNewTweet:(id)tweet;

@end
