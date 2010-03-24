//
//  RoundButtonCell.m
//  roundedbutton
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RoundButtonCell.h"
#import "NSColor_hex.h"
#import "NSBezierPath_RoundedRect.h"

// row height 35

@implementation RoundButtonCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // Construct rounded rect path
    NSRect bgRect = NSInsetRect(cellFrame, 10, 5);
    BOOL isActive = ([self intValue] == NSOnState) ? YES :NO;
    NSBezierPath *bgPath;
    // = [NSBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:7.0 active:isActive];
    // [[NSColor colorWithHexColorString:@"dbe4e7"] set];
    // [bgPath fill];

    if(isActive){
        bgPath = [NSBezierPath bezierPath];
        [[NSColor colorWithHexColorString:@"dbe4e7"] set];
        [bgPath moveToPoint:NSMakePoint(NSMaxX(bgRect)+5, NSMidY(bgRect))];
        [bgPath lineToPoint:NSMakePoint(NSMaxX(cellFrame)+2, NSMinY(bgRect)+5)];
        [bgPath lineToPoint:NSMakePoint(NSMaxX(cellFrame)+2, NSMaxY(bgRect)-5)];
        [bgPath closePath];
        [bgPath fill];
    }

    [super drawTitle:[self attributedTitle] withFrame:bgRect inView:controlView];
    // [super drawWithFrame:cellFrame inView:controlView];
}

- (NSMutableAttributedString *)setAttributedTitle:(NSString *)title
{
    NSColor *txtColor = [NSColor colorWithHexColorString:@"dbe4e7"];
    NSFont *txtFont = [NSFont boldSystemFontOfSize:12];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:txtFont,
                 NSFontAttributeName, txtColor,
                 NSForegroundColorAttributeName, nil];
    NSAttributedString *atted = [[[NSAttributedString alloc] initWithString:title
                                                                 attributes:dict] autorelease];
    [super setAttributedTitle:atted];
}

# if 0
    //on: NSRect bgRect = NSInsetRect(cellFrame, 0, 8);;
    bgRect = NSIntegralRect(bgRect);
    bgRect.origin.x += 0.5;
    bgRect.origin.y += 0.5;
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);
    int minYon = NSMinY(cellFrame);
    int midYon = NSMidY(cellFrame);
    int maxYon = NSMaxY(cellFrame);
    int minXon = NSMinX(cellFrame);
    int midXon = NSMidX(cellFrame);
    int maxXon = NSMaxX(cellFrame);
    float radius = 7.0;
    
    // Bottom edge and bottom-right curve
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxXon, minY) 
                                     toPoint:NSMakePoint(maxXon, midY) 
                                      radius:radius];
    
    // Right edge and top-right curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:radius];
    
    // Top edge and top-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:radius];
    
    // Left edge and bottom-left curve
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:radius];
    [bgPath closePath];
#endif
@end
