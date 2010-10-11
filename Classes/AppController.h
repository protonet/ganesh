//
//  AppController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>
#import "Tweet.h"
#import "Socket.h"
#import "GaneshStatusView.h"
#import "TimelineWindow.h"
#import "LIFOStack.h"

#import "MGTemplateEngine.h"

@class BonjourClientController;

@interface AppController : NSObject <MGTemplateEngineDelegate>{
  IBOutlet NSMenu *statusMenu;
  IBOutlet NSButton *daemonButton;
  IBOutlet NSTextView *postField;
  IBOutlet TimelineWindow *timelineWindow;
  IBOutlet WebView *webView;

  IBOutlet NSTableView *tableView;

  NSStatusItem *statusItem;
  GaneshStatusView *statusItemView;

  NSThread *edgeThread;
  NSTask *n2nApp;
  NSConnection *serverConnection;
  LIFOStack *inputStack;

  Socket *socket;
  BonjourClientController *bonjourClient;

  BOOL isTimelineVisible;
  int cur_networks;
}

- (IBAction)openPreferences:(id)sender;
- (IBAction)getVpn:(id)sender;

+ (AppController *)sharedController;

- (BOOL) copyPathWithforcedAuthentication:(NSString *)src toPath:(NSString *)dst error:(NSError **)error;
- (void)runApp;
- (NSString *) appSupportPath;
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)startDaemon:(id)sender;
- (BOOL) checkAndCopyHelper;

- (void)observeMessages;
- (void)createStatusBarItem;
- (IBAction)clearMessages:(id)sender;
- (void)postMessage:(id)sender;

- (void)installHotkey:(NSInteger)code withFlags:(NSUInteger)flags;

@end
