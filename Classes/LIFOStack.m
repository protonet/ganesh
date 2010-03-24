//
//  LIFOStack.m
//  aorc
//
//  Created by Reza Jelveh on 9/3/07.
//  Copyright 2007
//

#import "LIFOStack.h"


@implementation LIFOStack
- (id)init
{
	self = [super init];
	if (self)
	{
		queue = [[NSMutableArray alloc] init];
		[queue retain];
		
		size = 15;
		currentSize = 0;
        currentPos = 0;
	}
	return self;
}

- (id)initWithSize:(unsigned int)initSize
{
	self = [super init];
	if (self)
	{
		queue = [[NSMutableArray alloc] init];
		[queue retain];
		
		size = initSize;
		currentSize = 0;
	}
	return self;
}

- (void)dealloc
{
	[queue release];
	[super dealloc];
}

- (void)push:(id)newObject
{	
    currentPos = 0;
	if(currentSize < size){
		currentSize++;
    }
	else{
		[[queue objectAtIndex:currentSize-1] release];
		[queue removeObjectAtIndex:currentSize-1];
    }
	
	[queue addObject:[newObject copy]];
}

- (id)pop
{
	id object = nil;
	
	if(currentSize)
	{
		currentSize--;
		object = [queue objectAtIndex:currentSize];
        [object autorelease];
		[queue removeObjectAtIndex:currentSize];
	}
	return object;
}

- (id)previous{
    if(currentPos < currentSize){
        currentPos++;
    }

    return [queue objectAtIndex:currentSize-currentPos];
}

- (id)next{
    if(currentPos > 0){
        currentPos--;
    }
    return [queue objectAtIndex:currentSize-currentPos];
}

- (BOOL)hasItems
{
	return (currentSize ? YES : NO);
}

@end
