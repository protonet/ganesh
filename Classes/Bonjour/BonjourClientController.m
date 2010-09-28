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
@synthesize services;
@synthesize isConnected;
@synthesize connectedService;

-(void)awakeFromNib {
    services = [NSMutableArray new];
    self.browser = [[NSNetServiceBrowser new] autorelease];
    self.browser.delegate = self;
    self.isConnected = NO;
}

-(void)dealloc {
    self.connectedService = nil;
    self.browser = nil;
    [services release];
    [super dealloc];
}

-(IBAction)search:(id)sender {
    [self.browser searchForServicesOfType:@"_cocoaforsci._tcp." inDomain:@""];
}

-(IBAction)connect:(id)sender {
    NSNetService *remoteService = servicesController.selectedObjects.lastObject;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

#pragma mark Net Service Browser Delegate Methods
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    [servicesController addObject:aService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    [servicesController removeObject:aService];
    if ( aService == self.connectedService ) self.isConnected = NO;
}

-(void)netServiceDidResolveAddress:(NSNetService *)service {
    self.isConnected = YES;
    self.connectedService = service;
}

-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Could not resolve: %@", errorDict);
}

@end
