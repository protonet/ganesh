//
//  ganeshAppDelegate.m
//  ganesh
//
//  Created by Reza Jelveh on 27.07.10.
//  Copyright Flying Seagull 2010. All rights reserved.
//

#import "ganeshAppDelegate.h"

@implementation ganeshAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
