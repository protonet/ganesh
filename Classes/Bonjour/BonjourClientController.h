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
    BOOL isConnected;
    NSNetServiceBrowser *browser;
    NSNetService *connectedService;
    NSMutableArray *services;
    IBOutlet NSArrayController *servicesController;
}

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readwrite, retain) NSMutableArray *services;
@property (readwrite, assign) BOOL isConnected;
@property (readwrite, retain) NSNetService *connectedService;

@end
