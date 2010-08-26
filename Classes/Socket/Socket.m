//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#if !(TARGET_OS_IPHONE)
#import <SecurityFoundation/SFAuthorization.h>
// n2n includes
#include "edge.h"
#endif

#import "Socket.h"
#import "NSString+SBJSON.h"
#import "Messages.h"
#import "ChannelsController.h"
#import "Debug.h"
#import "M3EncapsulatedURLConnection.h"
#import "Reachability.h"
#import "AsyncSocket.h"

#import "NSString_urlEncode.h"

#define urlKey         @"serverUrl"
#define addressKey     @"serverAddress"
#define portKey        @"serverPort"
#define userNameKey    @"userName"
#define passwordKey    @"password"

#define kHTTPSuccess               200
#define kHTTPNotFound              404
#define kHTTPInternalServerError   500

@implementation Socket
@synthesize authenticated;
@synthesize authenticityToken;
@synthesize cookies;
@synthesize serverUrl;
@synthesize serverAddress;
@synthesize serverPort;
@synthesize userName;
@synthesize password;

#define PING_MSG     0
#define AUTH_MSG     1
#define RABBIT_MSG   2

#define READ_TIMEOUT 15.0

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    if([curReach currentReachabilityStatus] == NotReachable){
        [self cleanupBeforeSleep];
    }
    else {
        [self openSocket];
    }

}

- (void)initReachability
{
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
    if ([internetReach currentReachabilityStatus] == IsReachable) {
        [self openSocket];
    }
}

- (id)init {
    if(self = [super init]){
        DLog(@"init socket");
        
		asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];

#if !(TARGET_OS_IPHONE)
        // check on sleep and close socket
        NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
        [nc addObserver:self
               selector:@selector(cleanupBeforeSleep)
                   name:NSWorkspaceWillSleepNotification
                 object:nil];
        [nc addObserver:self
               selector:@selector(openSocket)
                   name:NSWorkspaceDidWakeNotification
                 object:nil];
#endif

        [self initPreferences];

        [self initReachability];

    }
    return self;
}

- (void) initPreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.serverUrl     = [defaults stringForKey:urlKey];
    self.serverAddress = [defaults stringForKey:addressKey];
    self.serverPort    = [defaults objectForKey:portKey];
    self.userName      = [defaults stringForKey:userNameKey];
    self.password      = [defaults stringForKey:passwordKey];

    if (self.serverUrl == nil) self.serverUrl = @"localhost:3000";
    if (self.serverAddress == nil) self.serverAddress = @"127.0.0.1";
    if (self.serverPort == nil) self.serverPort = [NSNumber numberWithInt:5000];
    if (self.userName == nil) self.userName = @"dudemeister";
    if (self.password == nil) self.password = @"geheim";

    [defaults addObserver:self forKeyPath:urlKey options:0 context:0];
    [defaults addObserver:self forKeyPath:addressKey options:0 context:0];
    [defaults addObserver:self forKeyPath:portKey options:0 context:0];
    [defaults addObserver:self forKeyPath:userNameKey options:0 context:0];
    [defaults addObserver:self forKeyPath:passwordKey options:0 context:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:urlKey]) {
        self.serverUrl = [object stringForKey:urlKey];
    }
    else if([keyPath isEqual:addressKey]){
        self.serverAddress = [object stringForKey:addressKey];
    }
    else if([keyPath isEqual:portKey]){
        self.serverPort = [object objectForKey:portKey];
    }
    else if([keyPath isEqual:userNameKey]){
        self.userName = [object stringForKey:userNameKey];
    }
    else if([keyPath isEqual:passwordKey]){
        self.password = [object stringForKey:passwordKey];
    }
}

- (void)cleanupBeforeSleep {
    self.authenticated = NO;
}

- (void)openSocket {
	// only do something if stream are not OK (not open)
    // or we have reachability
	if (![self streamsAreOk] && [internetReach currentReachabilityStatus] == IsReachable) {
        self.authenticated = NO;

        NSError *err = nil;
        if(![asyncSocket connectToHost:self.serverAddress onPort:[self.serverPort intValue] error:&err])
        {
            NSLog(@"Error: %@", err);
        }
	}
}

- (void)ping
{
    if (self.authenticated) {
        NSString *ping = [NSString stringWithFormat:@"{\"operation\":\"ping\"}"];
        NSData *pingData = [ping dataUsingEncoding:NSUTF8StringEncoding];
        [asyncSocket writeData:pingData withTimeout:-1 tag:PING_MSG];
    }
}

- (void)rescheduleConnect {
    [NSTimer scheduledTimerWithTimeInterval:(60.0f/4)
                                     target:self
                                   selector:@selector(openSocket)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)authenticateSocket {
    NSString *authUrl = [NSString stringWithFormat:@"%@/sessions/create_token.json?login=%@&password=%@",
                         self.serverUrl, self.userName, self.password];

    self.cookies = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authUrl]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60];

    [[M3EncapsulatedURLConnection alloc] initWithRequest:request
                                                delegate:self
                                           andIdentifier:@"authenticate"
                                             contextInfo:nil];
}

- (void)listChannels {
    NSString *url = [NSString stringWithFormat:@"%@/users/list_channels.json",
                     self.serverUrl];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60];

    [[M3EncapsulatedURLConnection alloc] initWithRequest:request
                                                delegate:self
                                           andIdentifier:@"list_channels"
                                             contextInfo:nil];
}

- (void)sendMessage:(NSString*)message {
	if(message != nil && [message length]>0)
    {
        if([self streamsAreOk]){
            NSNumber *channel_id = [[ChannelsController sharedController] selectedChannelId];
            if(!channel_id){
                channel_id = [NSNumber numberWithInt:1];
            }
            //        [self sendText:[NSString stringWithFormat:@"%@", message]];
            //tweet[message] message_channel-id=1 tweet[socket_id]=1 tweet[text_extension]=''
            NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%d&%@=%d&%@=%@",
                     @"authenticity_token", [self.authenticityToken urlEncode],
                     [@"tweet[message]" urlEncode], [message urlEncode],
                     @"message_channel_id", [channel_id intValue],
                     [@"tweet[socket_id]" urlEncode], 1,
                     [@"tweet[text_extension]" urlEncode], @""];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
            NSString *postUrl = [NSString stringWithFormat:@"%@/tweets", self.serverUrl];

            NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
            NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies];
            // we are just recycling the original request
            [request setAllHTTPHeaderFields:headers];

            [request setURL:[NSURL URLWithString:postUrl]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            DLog([[request allHTTPHeaderFields] description]);

            [[M3EncapsulatedURLConnection alloc] initWithRequest:request
                                                        delegate:self
                                                   andIdentifier:@"send_message"
                                                     contextInfo:nil];
        }
        else if ([internetReach currentReachabilityStatus] == IsReachable){
            [self openSocket];
        }
    }
}

- (BOOL)streamsAreOk {
    if ([asyncSocket isConnected]) {
        DLog(@"streams are ok!");
        return YES;
    } else {
        DLog(@"streams are NOT ok!");
        return NO;
    }
}

- (void)dealloc {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:urlKey];
    [defaults removeObserver:self forKeyPath:addressKey];
    [defaults removeObserver:self forKeyPath:portKey];
    [defaults removeObserver:self forKeyPath:userNameKey];
    [defaults removeObserver:self forKeyPath:passwordKey];

#if !(TARGET_OS_IPHONE)
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
#endif
	[super dealloc];
}


/**
 * Asynchronous callbacks
 */
- (void)processResponseHeaders:(NSHTTPURLResponse *)response {
    // store cookie if not set
    if(self.cookies == nil){
        self.cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
                                                              forURL:[NSURL URLWithString:self.serverUrl]];

        DLog([self.cookies description]);
    }
}

- (void)connection:(M3EncapsulatedURLConnection*)connection returnedWithResponse:(int)responseNo andData:(NSData*)responseData{
    // Get JSON as a NSString from NSData response
	NSString *response = [[[NSString alloc] initWithData:responseData
                                                encoding:NSUTF8StringEncoding] autorelease];

    if([[connection identifier] isEqualToString:@"authenticate"]){
        NSDictionary *authentication_dict = [response JSONValue];

        DLog(@"%@", response);
        DLog(@"%@", [authentication_dict objectForKey:@"token"]);

        self.authenticityToken = [authentication_dict objectForKey:@"authenticity_token"];
        if(self.authenticityToken == nil){
            [self rescheduleConnect];
        }
        else {
            // Now send the authentication-request
            NSString *auth = [NSString stringWithFormat:@"{\"operation\":\"authenticate\", \"payload\":{\"user_id\": %@, \"token\": \"%@\"}}",
                      [authentication_dict objectForKey:@"user_id"], [authentication_dict objectForKey:@"token"]];
            NSData *authData = [auth dataUsingEncoding:NSUTF8StringEncoding];
            [asyncSocket writeData:authData withTimeout:-1 tag:AUTH_MSG];

            self.authenticated = YES;
            [self listChannels];
            [NSTimer scheduledTimerWithTimeInterval:30
                                             target:self
                                           selector:@selector(ping)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    else if([[connection identifier] isEqualToString:@"list_channels"]){
        DLog(@"list channels %@", response);
        if(responseNo == kHTTPSuccess){
            [[ChannelsController sharedController] addChannels:[response JSONValue]];
        }
    }
    else if([[connection identifier] isEqualToString:@"send_message"]){
    }

    [connection release];
}

- (void)connection:(M3EncapsulatedURLConnection*)connection returnedWithError:(NSError *)error{
    [connection release];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if(tag == PING_MSG)
    {
        [NSTimer scheduledTimerWithTimeInterval:30
                                         target:self
                                       selector:@selector(ping)
                                       userInfo:nil
                                        repeats:NO];
    }
    else if(tag == AUTH_MSG)
    {
        [sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString * string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    DLog(@"%@", string);
    [[Messages sharedController] addMessageToTweets:string];
    // TODO: {"x_target":"socket_id","socket_id":"..."}
    [sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    self.authenticated = NO;
    if ([internetReach currentReachabilityStatus] == IsReachable) {
        [self rescheduleConnect];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (!self.authenticated) {
        [self authenticateSocket];
    }
}

@end
