//
//  NSString_truncate.m
//  ganesh
//
//  Created by Reza Jelveh on 25.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "NSString_truncate.h"


@implementation NSString (Truncate)

- (NSString *)stringWithTruncatingToLength:(unsigned)length {
	return [self stringTruncatedToLength:length direction:NSTruncateStart];
}

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom {
	return [self stringTruncatedToLength:length direction:truncateFrom withEllipsisString:@"…"];
}

- (NSString *)stringTruncatedToLength:(unsigned int)length direction:(unsigned)truncateFrom withEllipsisString:(NSString *)ellipsis{
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *immutableResult;
	
	if([result length] <= length) {
		return self; // no truncation, foolios
	}
	
	unsigned int charactersEachSide = length / 2;
	
	NSString *first;
	NSString *last;
	
	switch(truncateFrom) {
        case NSTruncateStart:
			[result insertString:ellipsis atIndex:length - [ellipsis length]];
			immutableResult  = [[result substringToIndex:length] copy];
			[result release];
			return [immutableResult autorelease];
			break;
		case NSTruncateMiddle:
			first = [result substringToIndex:charactersEachSide - [ellipsis length]+1];
			last = [result substringFromIndex:[result length] - charactersEachSide];
			immutableResult = [[[NSArray arrayWithObjects:first, last, NULL] componentsJoinedByString:ellipsis] copy];
			[result release];
			return [immutableResult autorelease];
			break;
		case NSTruncateEnd:
			[result insertString:ellipsis atIndex:[result length] - length + [ellipsis length] ];
			immutableResult  = [[result substringFromIndex:[result length] - length] copy];
			[result release];
			return [immutableResult autorelease];
	}
}

@end