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
	NSTask *n2nApp;
}

- (void)createStatusBarItem;
- (IBAction)pushedStatusBarItem:(id)sender;
- (void)updateStatusBarItem;
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


/** ganesh stuff **/
- (BOOL) checkAndCopyHelper;
- (BOOL) copyPathWithforcedAuthentication:(NSString *)src toPath:(NSString *)dst error:(NSError **)error;
- (void)runApp;
- (NSString *) appSupportPath;
- (void)startDaemon:(id)sender;
- (void) stopDaemon:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)showPreferences:(id)sender;
@end
