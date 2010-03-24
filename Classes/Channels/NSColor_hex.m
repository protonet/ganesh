//
//  NSColor_hex.m
//  roundedbutton
//
//  Created by Reza Jelveh on 24.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSColor_hex.h"


@implementation NSColor(Hex)

+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result    = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte   = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte  = (unsigned char)(colorCode);     // masks off high bits

    result = [NSColor
        colorWithCalibratedRed:(CGFloat)redByte    / 0xff
                         green:(CGFloat)greenByte / 0xff
                          blue:(CGFloat)blueByte   / 0xff
                         alpha:1.0];
    return result;
}


@end
