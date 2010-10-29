//
//  LoginController.m
//  ganesh
//
//  Created by Reza Jelveh on 29.10.10.
//  Copyright 2010 Protonet.info. All rights reserved.
//

#import "LoginController.h"

#import "Debug.h"

static LoginController *sharedLoginController = nil;

@implementation LoginController

+ (LoginController*)sharedController
{
    if (sharedLoginController == nil) {
        sharedLoginController = [[super allocWithZone:NULL] init];
    }
    return sharedLoginController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


- (void) showLoginWindow{
    [NSApp activateIgnoringOtherApps:YES];
    if (![loginWindow isVisible])
        [loginWindow center];
    [loginWindow makeKeyAndOrderFront:self];
    [loginWindow setLevel:NSFloatingWindowLevel];
}

- (void) showNodeFoundWindow{
    [NSApp activateIgnoringOtherApps:YES];
    if (![nodeFoundWindow isVisible])
        [nodeFoundWindow center];
    [nodeFoundWindow makeKeyAndOrderFront:self];
    [nodeFoundWindow setLevel:NSFloatingWindowLevel];
}

- (void) cancel:(id)sender {
    if ([nodeFoundWindow isVisible]){
        [nodeFoundWindow orderOut:sender];
    }
    else {
        [loginWindow orderOut:sender];
    }
}

- (void) setNodeSettings:(id)sender {
    DLog(@"set node settings clicked");
}

- (void) setLoginSettings:(id)sender {
}


@end
