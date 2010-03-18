//
//  LIFOStack.h
//  aorc
//
//  Created by Reza Jelveh on 9/3/07.
//  Copyright 2007
//

#import <Cocoa/Cocoa.h>


@interface LIFOStack : NSObject {
	NSMutableArray * queue;
	unsigned int size;
	unsigned int currentSize;
    // currentPos counts from the last position in the stack
    unsigned int currentPos;
}

- (void)push:(id)anArgument;
- (id)pop;
- (BOOL)hasItems;
- (id)previous;
- (id)next;

@end
