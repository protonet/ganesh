//
//  AppController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
  IBOutlet NSMenu *statusMenu;
  IBOutlet NSButton *daemonButton;
  NSStatusItem *statusItem;
  NSImage *statusImage;
  NSImage *statusHighlightImage;

  NSThread *edgeThread;
  NSTask *n2nApp;
}
- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)startDaemon:(id)sender;
- (BOOL) checkAndCopyHelper;
@end
