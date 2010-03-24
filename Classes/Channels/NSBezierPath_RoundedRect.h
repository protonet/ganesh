//
//  NSBezierPath_RoundedRect.h
//  ganesh
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 Protonet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (RoundedRect)
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius active:(BOOL)isActive;

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius active:(BOOL)isActive;
@end
