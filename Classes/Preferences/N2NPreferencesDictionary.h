//
//  N2NPreferencesDictionary.h
//  ClickToFlash
//
//  Created by Simone Manganelli on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface N2NPreferencesDictionary : NSMutableDictionary {
	NSMutableDictionary *realMutableDictionary;
	BOOL hasInited;
}

@end
