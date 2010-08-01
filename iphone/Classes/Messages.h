//
//  Messages.h
//  ganesh
//
//  Created by Reza Jelveh on 28.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

@interface Messages : TTURLRequestModel {
  NSArray*  _tweets;
}

@property (nonatomic, readonly) NSArray*  tweets;

@end
