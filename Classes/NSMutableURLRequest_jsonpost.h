//
//  NSMutableURLRequest_jsonpost.h
//  ganesh
//
//  Created by Reza Jelveh on 06.11.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

@interface NSMutableURLRequest (JSONPost)

+ (id)generateJSONPostRequest:(NSString *)post withURL:(NSString *)postUrl andCookies:(NSArray *)cookies;
- (id)initJSONPostRequest:(NSString *)post withURL:(NSString *)postUrl andCookies:(NSArray *)cookies;

@end
