//
//  GaneshFeedViewController.m
//  ganesh
//
//  Created by Reza Jelveh on 27.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "GaneshFeedViewController.h"
#import "ProtonetDataSource.h"


@implementation GaneshFeedViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
  if (self = [super init]) {
    self.title = @"Twitter feed";
    self.variableHeightRows = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  self.dataSource = [[[ProtonetDataSource alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}


@end
