//
//  ProtonetDataSource.m
//  ganesh
//
//  Created by Reza Jelveh on 28.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "ProtonetDataSource.h"
#import "Messages.h"
#import "Tweet.h"

@implementation ProtonetDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _meepModel = [[Messages alloc] init];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_meepModel);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
  return _meepModel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
  NSMutableArray* items = [[NSMutableArray alloc] init];

  for (Tweet* tweet in [_meepModel messages]) {
    TTStyledText* styledText = [TTStyledText textFromXHTML:tweet.message lineBreaks:YES URLs:YES];

    TTDASSERT(nil != styledText);
    [items addObject:[TTTableStyledTextItem itemWithText:styledText]];
  }

  self.items = items;
  TT_RELEASE_SAFELY(items);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return NSLocalizedString(@"Updating Twitter feed...", @"Twitter feed updating text");
  } else {
    return NSLocalizedString(@"Loading Twitter feed...", @"Twitter feed loading text");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return NSLocalizedString(@"No tweets found.", @"Twitter feed no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return NSLocalizedString(@"Sorry, there was an error loading the Twitter stream.", @"");
}


@end
