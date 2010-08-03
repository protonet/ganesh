//
//  GaneshFeedViewController.m
//  ganesh
//
//  Created by Reza Jelveh on 27.07.10.
//  Copyright 2010 Flying Seagull. All rights reserved.
//

#import "GaneshFeedViewController.h"
#import "ProtonetDataSource.h"
#import "Socket.h"

@implementation GaneshFeedViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
  if (self = [super init]) {
    self.title = @"Protonet feed";
    self.variableHeightRows = YES;

    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose
                                                       target:self
                                                       action:@selector(send)] autorelease];    

    socket = [[Socket alloc] init];
  }

  return self;
}

- (void)dealloc {
    [[TTNavigator navigator].URLMap removeURL:@"tt://post"];
    [socket release];
    [super dealloc];
}

- (void)send {
    TTPostController *postController = [[TTPostController alloc] init]; 
    postController.delegate = self; // self must implement the TTPostControllerDelegate protocol 
    self.popupViewController = postController; 
    postController.superController = self; // assuming self to be the current UIViewController 
    [postController showInView:self.view animated:YES]; 
    [postController release]; 

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
  self.dataSource = [[[ProtonetDataSource alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return TTIsSupportedOrientation(interfaceOrientation);
}

- (void)postControllerDidCancel:(TTPostController*)postController{

    [postController dismissModalViewControllerAnimated:YES];
}

- (void)postController:(TTPostController*)postController
           didPostText:(NSString*)text
            withResult:(id)result
{
    [socket sendMessage:text];
}

- (UIViewController*)post:(NSDictionary*)query {
  TTPostController* controller = [[[TTPostController alloc] init] autorelease];
  controller.originView = [query objectForKey:@"__target__"];
  return controller;
}

@end
