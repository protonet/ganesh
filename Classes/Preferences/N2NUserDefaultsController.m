//
//  N2NUserDefaultsController.m
//  ClickToFlash
//
//  Created by Simone Manganelli on 2009-05-23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "N2NUserDefaultsController.h"

static N2NUserDefaultsController *sharedInstance = nil;

#define domainKey @"com.protonet.n2n"

@implementation N2NUserDefaultsController

+ (N2NUserDefaultsController *)standardUserDefaults;
{
	if (! sharedInstance) sharedInstance = [[self alloc] init];
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone;
{
	if (sharedInstance) {
		return [sharedInstance retain];
	} else {
		return [super allocWithZone:zone];
	}
}

- (id)init;
{
	if (! sharedInstance) {
		if ((self = [super init])) {
			hasInited = YES;
		}
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder;
{
	if (! sharedInstance) {
		if ((self = [super init])) {
			hasInited = YES;
		}
	}
	
	return self;
}

- (void)dealloc;
{
	[userDefaultsDict release];
	[super dealloc];
}

- (void)setUpExternalPrefsDictionary;
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pluginDefaultsDidChange:)
												 name:@"N2NDefaultsDidChange"
											   object:nil];
	[[NSUserDefaults standardUserDefaults] addSuiteNamed:domainKey];
	[self setValues:[N2NPreferencesDictionary dictionaryWithDictionary:
					 [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainKey]]
	 ];	
	[[NSUserDefaults standardUserDefaults] removeSuiteNamed:domainKey];
}

- (N2NPreferencesDictionary *)values;
{
	// I have no idea why, but -init, -initWithDefaults:initialValues:,
	// and +sharedUserDefaultsController all never seem to get called.  Only
	// -awakeFromNib gets called, and that's too late for bindings;
	
	// so instead, we just wait for the initial call to access values,
	// and if that call detects that the user defaults dictionary hasn't
	// been set up yet, it sets it up and *then* returns the values
	
	if (! userDefaultsDict) {
		[self setUpExternalPrefsDictionary];
	}
	return userDefaultsDict;
}

- (N2NPreferencesDictionary *)dictionaryRepresentation;
{
	return [self values];
}

- (void)setValues:(N2NPreferencesDictionary *)newUserDefaultsDict;
{
	N2NPreferencesDictionary *newDictCopy = [newUserDefaultsDict copy];
	if (! userDefaultsDict) userDefaultsDict = [[N2NPreferencesDictionary alloc] init]; 
	[userDefaultsDict removeAllObjects];
	[userDefaultsDict addEntriesFromDictionary:newDictCopy];
	[newDictCopy release];
}

- (void)pluginDefaultsDidChange:(NSNotification *)notification;
{
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:userDefaultsDict
													   forName:domainKey];
}

- (id)objectForKey:(NSString *)defaultName;
{
	return [[self values] objectForKey:defaultName];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName;
{
	[[self values] setObject:value forKey:defaultName];
}

- (int)integerForKey:(NSString *)defaultName;
{
	return [[[self values] objectForKey:defaultName] intValue];
}

- (void)setIntegerForKey:(int)value forKey:(NSString *)defaultName;
{
	[[self values] setObject:[NSNumber numberWithInt:value] forKey:defaultName];
}

- (BOOL)boolForKey:(NSString *)defaultName;
{
	return [[[self values] objectForKey:defaultName] boolValue];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
{
	[[self values] setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName;
{
	id value = [[self values] objectForKey:defaultName];
	id valueToReturn = nil;
	if ([[value className] isEqualToString:@"NSCFArray"]) valueToReturn = value;
	return valueToReturn;
}

- (void)removeObjectForKey:(NSString *)defaultName;
{
	[[self values] removeObjectForKey:defaultName];
}

@end
