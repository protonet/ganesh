//
//  BonjourClientController.m
//  ganesh
//
//  Created by Reza Jelveh on 28.09.10.
//  Based on the code described on http://www.macresearch.org/cocoa-scientists-part-xxviii-bonjour-and-how-do-you-do
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "BonjourClientController.h"
#import "LoginController.h"
#import "Debug.h"


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
    self.service.delegate = self;
    [self.service resolveWithTimeout:10];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    self.service = aService;
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // only show the new network found dialog if it's not the same as our current one
    if (![[defaults stringForKey:@"serverAddress"] isEqualToString:[self.service hostName]]) {
        [[LoginController sharedController] showNodeFoundWindow:[self.service hostName]];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    DLog(@"Couldn't resolve protonet node");
}


@end
