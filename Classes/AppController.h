//
//  AppController.h
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Acculogic GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
  NSImage *statusImage;
  NSImage *statusHighlightImage;
}
- (IBAction)connect:(id)sender;
@end
