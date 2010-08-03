//
//  GaneshFeedViewController.h
//  ganesh
//
//  Created by Reza Jelveh on 27.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Socket;

@interface GaneshFeedViewController : TTTableViewController <UITextFieldDelegate> {
    Socket *socket;
}

@end
