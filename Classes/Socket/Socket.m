//
//  Socket.m
//  Socket
//
//  Created by jelveh on 07.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <SecurityFoundation/SFAuthorization.h>

#import "Socket.h"
#import "JSON.h"
#import "Messages.h"
#import "Debug.h"
#import "M3EncapsulatedURLConnection.h"

#import "NSString_urlEncode.h"

// n2n includes
#include "edge.h"

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

- (id)init {
    if(self = [super init]){
        DLog(@"init socket");
        host = [NSHost currentHost];

        [serverAnswerField setObjectValue:[host name]];

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

        [self initPreferences];
        [self openSocket];
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
	[self closeStreams];
    self.authenticated = NO;
}

- (void)openSocket {
	// only do something if stream are not OK (not open)
	if (![self streamsAreOk]) {
        self.authenticated = NO;

		host = [NSHost hostWithAddress:self.serverAddress];
		[NSStream getStreamsToHost:host port:[self.serverPort intValue] inputStream:&inputStream outputStream:&outputStream];
		[self openStreams];
	}
}

- (void)ping
{
    if (self.authenticated) {
        [self sendText:[NSString stringWithFormat:@"{\"operation\":\"ping\"}"]];
        [NSTimer scheduledTimerWithTimeInterval:30
                                         target:self
                                       selector:@selector(ping)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)rescheduleConnect {
    [self closeStreams];
    [NSTimer scheduledTimerWithTimeInterval:(60.0f/4)
                                     target:self
                                   selector:@selector(openSocket)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)authenticateSocket {
    NSString *authUrl = [NSString stringWithFormat:@"http://%@/sessions/create_token.json?login=%@&password=%@",
                         self.serverUrl, self.userName, self.password];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authUrl]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60];

    [[M3EncapsulatedURLConnection alloc] initWithRequest:request
                                                delegate:self
                                           andIdentifier:@"authenticate"
                                             contextInfo:nil];
}

- (void)listChannels {
    NSString *url = [NSString stringWithFormat:@"http://%@/channels/list.json?token=%@",
                     self.serverUrl, self.authenticityToken];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60];

    [[M3EncapsulatedURLConnection alloc] initWithRequest:request
                                                delegate:self
                                           andIdentifier:@"authenticate"
                                             contextInfo:nil];
}

- (void)openStreams {
    [inputStream retain];
    [outputStream retain];
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)closeStreams {
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    [inputStream release];
    [outputStream release];
    inputStream = nil;
    outputStream = nil;
}

- (void)sendMessage:(NSString*)message {
	if([self streamsAreOk] && message != nil && [message length]>0)
    {
        
//        [self sendText:[NSString stringWithFormat:@"%@", message]];
        //tweet[message] message_channel-id=1 tweet[socket_id]=1 tweet[text_extension]=''
        NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%d&%@=%d&%@=%@",
                          @"authenticity_token", [self.authenticityToken urlEncode],
                          [@"tweet[message]" urlEncode], [message urlEncode],
                          @"message_channel_id", 1,
                          [@"tweet[socket_id]" urlEncode], 1,
                          [@"tweet[text_extension]" urlEncode], @""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        NSString *postUrl = [NSString stringWithFormat:@"http://%@/tweets", self.serverUrl];

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
        
        NSData* urlData; //returndata
        NSURLResponse *response;
        NSError *error;
        
        urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        DLog(@"urlData %@", [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]);
    }
}

- (void)sendText:(NSString *)string {
    NSString * stringToSend = [NSString stringWithFormat:@"%@\n", string];
    NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    if (outputStream && [self streamsAreOk]) {
        int remainingToWrite = [dataToSend length];
        void * marker = (void *)[dataToSend bytes];
        while (0 < remainingToWrite) {
            int actuallyWritten = 0;
            actuallyWritten = [outputStream write:marker maxLength:remainingToWrite];
            remainingToWrite -= actuallyWritten;
            marker += actuallyWritten;
        }
    } else {
		[serverAnswerField setStringValue:@"trying to open socket, try again!"];
	}

}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    NSInputStream * istream;
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:;
            uint8_t oneByte;
            int actuallyRead = 0;
            istream = (NSInputStream *)aStream;
            if (!dataBuffer) {
                dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
            }
            actuallyRead = [istream read:&oneByte maxLength:1];
            if (actuallyRead == 1) {
                [dataBuffer appendBytes:&oneByte length:1];
            }
            if (oneByte == '\n' || oneByte == '\0') {
					// We've got the carriage return at the end of the echo. Let's set the string.
                NSString * string = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
				[serverAnswerField setStringValue:string];
                DLog(string);
				[[Messages sharedController] addMessageToTweets:string];
                // TODO: {"x_target":"socket_id","socket_id":"..."}
                [string release];
                [dataBuffer release];
                dataBuffer = nil;
            }
            break;
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
            self.authenticated = NO;
            [self rescheduleConnect];
            break;
        case NSStreamEventHasSpaceAvailable:
            if (aStream == outputStream) {
                if (!self.authenticated) {
                    [self authenticateSocket];
                }
            }
            break;
        default:
            break;
    }
}

- (BOOL)streamsAreOk {
	if ([inputStream streamStatus] == NSStreamStatusOpen &&
		[outputStream streamStatus] == NSStreamStatusOpen) {
		DLog(@"streams are ok!");
		return YES;
	} else {
		DLog(@"streams are NOT ok!");
		return NO;
	}
}

- (BOOL)streamsAreOpening {
	if ([inputStream streamStatus] == NSStreamStatusOpening &&
		[outputStream streamStatus] == NSStreamStatusOpening) {
		DLog(@"streams are opening!");
		return YES;
	} else {
		DLog(@"streams are NOT opening!");
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

	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super dealloc];
}


/**
 * Asynchronous callbacks
 */
- (void)processResponseHeaders:(NSHTTPURLResponse *)response {
    NSString *url = [NSString stringWithFormat:@"http://%@", self.serverUrl];

    // store cookie
    self.cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
                                                          forURL:[NSURL URLWithString:url]];

    DLog([self.cookies description]);
}

- (void)connection:(M3EncapsulatedURLConnection*)connection returnedWithResponse:(int)responseNo andData:(NSData*)responseData{
    SBJsonParser *parser = [[SBJsonParser alloc] init];

    // Get JSON as a NSString from NSData response
	NSString *json_string = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];

    if([[connection identifier] isEqualToString:@"authenticate"]){
        NSDictionary *authentication_dict = [parser objectWithString:json_string];

        DLog(@"%@", json_string);
        DLog(@"%@", [authentication_dict objectForKey:@"token"]);

        self.authenticityToken = [authentication_dict objectForKey:@"authenticity_token"];
        if(self.authenticityToken == nil){
            [self rescheduleConnect];
        }
        else {
            // Now send the authentication-request
            [self sendText:[NSString stringWithFormat:@"{\"operation\":\"authenticate\", \"payload\":{\"user_id\": %@, \"token\": \"%@\"}}",
                        [authentication_dict objectForKey:@"user_id"], [authentication_dict objectForKey:@"token"]]];

            self.authenticated = YES;
            [self listChannels];
            [NSTimer scheduledTimerWithTimeInterval:30
                                             target:self
                                           selector:@selector(ping)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
    else if([connection identifier:@"list_channels"]){
        DLog(@"list channels %@", json_string);
        if(responseNo == kHTTPSuccess){
            NSDictionary *dict = [parser objectWithString:json_string];

            DLog([dict description]);
        }
    }

    [responseData release];
    [connection release];
}

- (void)connection:(M3EncapsulatedURLConnection*)connection returnedWithError:(NSError *)error{
    [connection release];
}

@end
