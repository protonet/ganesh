//
//  ganeshAppDelegate.m
//  ganesh
//
//  Created by Reza Jelveh on 27.07.10.
//  Copyright Flying Seagull 2010. All rights reserved.
//

#import "ganeshAppDelegate.h"
#import "GaneshFeedViewController.h"

@implementation ganeshAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    TTNavigator* navigator = [TTNavigator navigator];
    navigator.persistenceMode = TTNavigatorPersistenceModeNone;

    TTURLMap* map = navigator.URLMap;

    [map from:@"*" toViewController:[TTWebController class]];
    [map from:kAppRootURLPath toViewController:[GaneshFeedViewController class]];

    if (![navigator restoreViewControllers]) {
        [navigator openURLAction:[TTURLAction actionWithURLPath:kAppRootURLPath]];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)navigator:(TTNavigator*)navigator shouldOpenURL:(NSURL*)URL {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}

@end
