//
//  Socket.h
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tweet.h"
#import "PreferenceController.h"

@interface Socket : NSObject {
	
	PreferenceController * preferences;
	
	IBOutlet NSTextField * inputField;
	IBOutlet NSTextField * serverAnswerField;
	NSInputStream * inputStream;
	NSOutputStream * outputStream;
	NSMutableData * dataBuffer;
	NSHost * host;
	
	IBOutlet NSTableView *tableView;
    NSMutableArray *tweetList;
	
	IBOutlet NSMenu *menuForStatusItem;
	NSStatusItem *statusItem;
	
	int messageCounter;
	BOOL socketAuthenticated;
	
	// images for status item states
	NSImage *statusNoVpnNoMessageImage;
	NSImage *statusNoVpnHasMessageImage;	
	NSImage *statusHasVpnNoMessageImage;
	NSImage *statusHasVpnHasMessageImage;
}

- (void)createStatusBarItem;
- (IBAction)pushedStatusBarItem:(id)sender;
- (void)notifyStatusBarItem;
- (void)resetStatusBarItem;
- (void)addMenuItemForTweet:(Tweet *)tweet;

- (IBAction)sendMessageAndClearInput:(id)sender;

- (void)openSocket;
- (void)openStreams;
- (void)closeStreams;
- (void)authenticateSocket;

- (BOOL)streamsAreOk;
- (BOOL)streamsAreOpening;
- (void)sendText:(NSString *)string;
- (void)addMessageToTweets:(NSString *)string;
- (IBAction)clearMessages:(id)sender;

@end
