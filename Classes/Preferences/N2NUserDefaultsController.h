//
//  N2NUserDefaultsController.h
//  ClickToFlash
//
//  Created by Simone Manganelli on 2009-05-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "N2NPreferencesDictionary.h"


@interface N2NUserDefaultsController : NSUserDefaultsController {
	N2NPreferencesDictionary *userDefaultsDict;
	BOOL hasInited;
}

+ (N2NUserDefaultsController *)standardUserDefaults;
- (void)setUpExternalPrefsDictionary;

- (void)pluginDefaultsDidChange:(NSNotification *)notification;
- (N2NPreferencesDictionary *)values;
- (N2NPreferencesDictionary *)dictionaryRepresentation;
- (void)setValues:(N2NPreferencesDictionary *)newUserDefaultsDict;

- (id)objectForKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (int)integerForKey:(NSString *)defaultName;
- (void)setIntegerForKey:(int)value forKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (NSArray *)arrayForKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;


@end
