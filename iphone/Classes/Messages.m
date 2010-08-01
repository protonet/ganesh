//
//  Messages.m
//  ganesh
//
//  Created by Reza Jelveh on 28.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "Messages.h"


@implementation Messages

@synthesize tweets      = _tweets;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
      NSLog(@"initialized");
      [super didFinishLoad];
  }

  return self;
}
- (void) dealloc {
  TT_RELEASE_SAFELY(_tweets);
  [super dealloc];
}

- (void)didStartLoad {
    NSLog(@"didStartLoad");
}

- (void)didFinishLoad {
    NSLog(@"didFinishLoad");
}

- (void)didFailLoadWithError:(NSError*)error {
    NSLog(@"didFail");
}

- (void)didCancelLoad {
    NSLog(@"didCancel");
}

- (void)beginUpdates {
    NSLog(@"beginUpdates");
}

- (void)endUpdates {
    NSLog(@"endUpdates");
}

- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}

- (void)didChange {
    NSLog(@"didChange");
}


@end
