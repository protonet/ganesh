//
//  BonjourClientController.m
//  ganesh
//
//  Created by Reza Jelveh on 28.09.10.
//  Based on the code described on http://www.macresearch.org/cocoa-scientists-part-xxviii-bonjour-and-how-do-you-do
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "BonjourClientController.h"


@implementation BonjourClientController

@synthesize browser;
@synthesize service;
@synthesize isInRange;

-(void)search {
    [self.browser searchForServicesOfType:@"_protonet._tcp." inDomain:@""];
}

-(id)init {
    if (self = [super init]){
        self.browser = [[NSNetServiceBrowser new] autorelease];
        self.browser.delegate = self;

        [self search];
    }
    return self;
}

-(void)dealloc {
    self.browser = nil;
    self.service = nil;
    [super dealloc];
}

#pragma mark Net Service Browser Delegate Methods
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    self.service = aService;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    self.service = aService;
}

@end
