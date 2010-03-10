//
//  NSString_urlEncode.m
//  ganesh
//
//  Created by Reza Jelveh on 3/10/10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "NSString_urlEncode.h"


@implementation NSString(UrlEncode)

- (NSString *)urlEncode
{
    NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return [result autorelease];
}

@end
