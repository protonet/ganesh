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
	if(currentSize < size)
		currentSize++;
	else
		[queue removeObjectAtIndex:0];
	
	[queue addObject:[newObject copy]];
}

- (id)pop
{
	id object = nil;
	
	if(currentSize)
	{
		currentSize--;
		object = [queue objectAtIndex:currentSize];
        [object release];
		[queue removeObjectAtIndex:currentSize];
	}
	return object;
}

- (BOOL)hasItems
{
	return (currentSize ? YES : NO);
}

@end
