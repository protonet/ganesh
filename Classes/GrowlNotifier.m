//
//  GrowlNotifier.m
//  ganesh
//
//  Created by Reza Jelveh on 2010-02-14
//  Copyright 2010 Protonet.info. All rights reserved.
//
#import "GrowlNotifier.h"
#import "Tweet.h"

static GrowlNotifier *sharedGrowlNotifier = nil;

@implementation GrowlNotifier

/**
 * Growl registration delegate
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray *growlNotifications = [NSArray arrayWithObjects:@"Tweet", nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:growlNotifications, GROWL_NOTIFICATIONS_ALL, growlNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

+ (GrowlNotifier*)sharedController
{
    if (sharedGrowlNotifier == nil) {
        sharedGrowlNotifier = [[super allocWithZone:NULL] init];
    }
    return sharedGrowlNotifier;
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

- (id)init
{
    if(self = [super init]){
        // initialize growl
        if([GrowlApplicationBridge isGrowlInstalled]) {
            [GrowlApplicationBridge setGrowlDelegate:self];
        }

        // watch for changes in growl pref pane
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        enableGrowl     = [defaults boolForKey:@"enableGrowl"];

        [defaults addObserver:self forKeyPath:@"enableGrowl" options:0 context:0];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"enableGrowl"]) {
        enableGrowl = [object boolForKey:@"enableGrowl"];
    }
}


- (void)showNewTweet:(Tweet*)tweet
{
    if (enableGrowl && tweet) {
        [GrowlApplicationBridge notifyWithTitle:tweet.author
                                    description:tweet.message
                               notificationName:@"Tweet"
                                       iconData:[tweet.userImage TIFFRepresentation]
                                       priority:0
                                       isSticky:FALSE
                                   clickContext:nil];
    }

}

@end
