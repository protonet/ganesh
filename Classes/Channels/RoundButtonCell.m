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
#define kChannelBadgeWidth 30

@implementation RoundButtonCell

- (NSAttributedString *)attributedObjectCountValue
{
    NSMutableAttributedString *attrStr;
    NSFontManager *fm = [NSFontManager sharedFontManager];
    NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
    [nf setLocalizesFormat:YES];
    [nf setFormat:@"0"];
    [nf setHasThousandSeparators:YES];
    NSString *contents = [nf stringFromNumber:[NSNumber numberWithInt:5]];
    attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
    NSRange range = NSMakeRange(0, [contents length]);

    // Add font attribute
    [attrStr addAttribute:NSFontAttributeName value:[fm convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[[NSColor whiteColor] colorWithAlphaComponent:0.85] range:range];

    return attrStr;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // Construct rounded rect path
    NSRect bgRect = NSInsetRect(cellFrame, 10, 5);
    BOOL isActive = ([self intValue] == NSOnState) ? YES :NO;
    NSBezierPath *bgPath;

    if(isActive){
        // drawing the triangle on the side
        bgPath = [NSBezierPath bezierPath];
        [[NSColor colorWithHexColorString:@"dbe4e7"] set];
        [bgPath moveToPoint:NSMakePoint(NSMaxX(bgRect)+5, NSMidY(bgRect))];
        [bgPath lineToPoint:NSMakePoint(NSMaxX(cellFrame)+2, NSMinY(bgRect)+5)];
        [bgPath lineToPoint:NSMakePoint(NSMaxX(cellFrame)+2, NSMaxY(bgRect)-5)];
        [bgPath closePath];
        [bgPath fill];
    }

#if 1
    NSRect myRect = NSInsetRect(cellFrame, 5, 8);
    myRect.size.width = kChannelBadgeWidth;
    bgPath = [NSBezierPath bezierPathWithRoundedRect:myRect cornerRadius:9.0];
    [[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
    [bgPath fill];

    // draw attributed string centered in area
    NSRect counterStringRect;
    NSAttributedString *counterString = [self attributedObjectCountValue];
    counterStringRect.size = [counterString size];
    counterStringRect.origin.x = myRect.origin.x + ((myRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
    counterStringRect.origin.y = myRect.origin.y + ((myRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
    [counterString drawInRect:counterStringRect];


    bgRect.origin.x += kChannelBadgeWidth;
    bgRect.size.width -= kChannelBadgeWidth;
#endif
    [super drawTitle:[self attributedTitle] withFrame:bgRect inView:controlView];
    // [super drawWithFrame:cellFrame inView:controlView];
}

- (NSMutableAttributedString *)setAttributedTitle:(NSString *)title active:(BOOL)isActive
{
    NSColor *txtColor = [NSColor colorWithHexColorString:@"dbe4e7"];
    NSShadow *txtShadow = [[[NSShadow alloc] init] autorelease];

    if(isActive){
        [txtShadow setShadowColor: [NSColor colorWithCalibratedRed:1.0
                            green: 1.0
                             blue: 0.0
                            alpha: 0.9]];
        [txtShadow setShadowOffset: NSMakeSize(0.5, -0.5)];
        [txtShadow setShadowBlurRadius: 1.0];
    }

    NSFont *txtFont = [NSFont boldSystemFontOfSize:12];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:txtFont, NSFontAttributeName,
                 txtColor, NSForegroundColorAttributeName,
                 txtShadow, NSShadowAttributeName,
                 nil];
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
