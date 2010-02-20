//
//  IPFormatter.m
//  ganesh
//
//  Created by Reza Jelveh on 18.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IPFormatter.h"

@implementation IPFormatter

- (NSString *)stringForObjectValue:(id)obj
{
	if([obj isKindOfClass:[NSString class]])
	{
        return obj;
	}
	else
	{
        return @"127.0.0.1";
	}
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string
	  errorDescription:(NSString **)error
{
	//Remove any characters that are not in [0-9xX.]
	NSMutableString *tempString          = [NSMutableString
											stringWithString: string];
	NSCharacterSet  *illegalCharacters    = [[NSCharacterSet
											  characterSetWithCharactersInString:@"0123456789xX."] invertedSet];
	NSRange        illegalCharacterRange = [tempString
											rangeOfCharacterFromSet: illegalCharacters];
	
	while(illegalCharacterRange.location != NSNotFound)
	{
		[tempString deleteCharactersInRange: illegalCharacterRange];
		illegalCharacterRange = [tempString rangeOfCharacterFromSet:
								 illegalCharacters];
	}
	
	string          = tempString;
	
	NSArray *parts  = [string componentsSeparatedByString: @"."];
	
	switch([parts count])
	{
		case 0:
            *obj  = @"127.0.0.1";
			return TRUE;
			
		case 1:
            *obj  = [NSString stringWithFormat:@"%@.0.0.1", [parts objectAtIndex: 0]];
			return TRUE;
			
		case 2:
            *obj  = [NSString stringWithFormat:@"%@.%@.0.1", [parts objectAtIndex: 0],
                          [parts objectAtIndex:1]];
			return TRUE;
			
		case 3:
            *obj  = [NSString stringWithFormat:@"%@.%@.%@.1", [parts objectAtIndex: 0],
                          [parts objectAtIndex:1],
                          [parts objectAtIndex:2]];
			return TRUE;
			
		case 4:
            *obj  = [NSString stringWithFormat:@"%@.%@.%@.%@", [parts objectAtIndex: 0],
                          [parts objectAtIndex:1],
                          [parts objectAtIndex:2],
                          [parts objectAtIndex:3]];
			return TRUE;
			
		default:
			return FALSE;
	}
}

@end

