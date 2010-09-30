//
//  BonjourClientController.h
//  ganesh
//
//  Created by Reza Jelveh on 28.09.10.
//  Based on the code described on http://www.macresearch.org/cocoa-scientists-part-xxviii-bonjour-and-how-do-you-do
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BonjourClientController : NSObject {
    NSNetServiceBrowser *browser;
    NSNetService *service;

    BOOL isInRange;
}

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readwrite, retain) NSNetService *service;
@property (readwrite, assign) BOOL isInRange;

@end
