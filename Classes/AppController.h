//
//  AppController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tweet.h"

@interface AppController : NSObject {
  IBOutlet NSMenu *statusMenu;
  IBOutlet NSButton *daemonButton;

  IBOutlet NSTableView *tableView;
  NSMutableArray *tweetList;
  int messageCounter;

  NSStatusItem *statusItem;

  NSThread *edgeThread;
  // images for status item states
  NSImage *statusNoVpnNoMessageImage;
  NSImage *statusNoVpnHasMessageImage;	
  NSImage *statusHasVpnNoMessageImage;
  NSImage *statusHasVpnHasMessageImage;
  NSTask *n2nApp;
}

+ (AppController *)sharedController;

- (BOOL) copyPathWithforcedAuthentication:(NSString *)src toPath:(NSString *)dst error:(NSError **)error;
- (void)runApp;
- (NSString *) appSupportPath;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)startDaemon:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (BOOL) checkAndCopyHelper;

- (void)createStatusBarItem;
- (void)resetStatusBarItem;
- (IBAction)pushedStatusBarItem:(id)sender;
- (void)updateStatusBarItem;
- (IBAction)clearMessages:(id)sender;

@end
