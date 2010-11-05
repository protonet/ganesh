//
//  NSMutableURLRequest_jsonpost.m
//  ganesh
//
//  Created by Reza Jelveh on 06.11.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "NSMutableURLRequest_jsonpost.h"


@implementation NSMutableURLRequest(JSONPost)

+ (id)generateJSONPostRequest:(NSString *)post withURL:(NSString *)postUrl andCookies:(NSArray *)cookies
{
    return [[[self alloc] initJSONPostRequest:post withURL:postUrl andCookies:cookies] autorelease];
}

- (id)initJSONPostRequest:(NSString *)post withURL:(NSString *)postUrl andCookies:(NSArray *)cookies
{
    if (self = [super init]) {
        NSData *postData     = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

        NSDictionary *headers        = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        // we are just recycling the original request
        [self setAllHTTPHeaderFields:headers];

        [self setURL:[NSURL URLWithString:postUrl]];
        [self setHTTPMethod:@"POST"];
        [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [self setValue:@"application/jsonrequest" forHTTPHeaderField:@"Content-Type"];
        [self setValue:@"application/jsonrequest" forHTTPHeaderField:@"Accept"];
        [self setHTTPBody:postData];

    }
    return self;
}

@end
