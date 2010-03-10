//
//  NSScroller_Tweetie.m
//  ganesh
//
//  Created by Reza Jelveh on 10.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import "NSScroller_Tweetie.h"

@implementation NSScroller (Tweetie)

- (void)drawRect:(NSRect)thisRect {
	[self setArrowsPosition:NSScrollerArrowsNone];
	NSBezierPath *thisPath = [NSBezierPath bezierPath];
	[thisPath appendBezierPathWithRect:thisRect];
	[[NSColor colorWithCalibratedWhite:1 alpha:1] setFill];
	[thisPath fill];
	NSRect insetRect;
	if (thisRect.size.width && thisRect.size.height) {
		insetRect = NSInsetRect([self rectForPart:NSScrollerKnob], 3, 0);
		insetRect.origin.x -=2;
	}else{
		insetRect = NSInsetRect([self rectForPart:NSScrollerKnob], 0, 3);
		insetRect.origin.y -=2;
	}
	
	NSBezierPath *knobPath = [NSBezierPath bezierPath];
	[knobPath appendBezierPathWithRoundedRect:insetRect xRadius:4 yRadius:4];
	[[[NSColor darkGrayColor] colorWithAlphaComponent:.35] setFill];
	[knobPath fill];	
}
