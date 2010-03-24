//
//  NSString_truncate.h
//  ganesh
//
//  Created by Reza Jelveh on 25.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSTruncateStart  0
#define NSTruncateMiddle 1
#define NSTruncateEnd    2

@interface NSString (Truncate)
- (NSString *)stringWithTruncatingToLength:(unsigned)length;
- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom;
- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom withEllipsisString:(NSString *)ellipsis;
@end
