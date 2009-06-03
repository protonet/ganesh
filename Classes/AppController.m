//
//  AppController.m
//  protococoa
//
//  Created by Reza Jelveh on 6/3/09.
//  Copyright 2009 Acculogic GmbH. All rights reserved.
//

#import "AppController.h"


@implementation AppController

- (void) threadMethod:(id)theObject
{
    NSLog(@"thread started");
    while(1){
    }
}

- (IBAction)connect:(id)sender {
    edgeThread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(threadMethod:)
                                           object:nil];
    [edgeThread start];
#if 0
    NSLog(@"test log");

    if(tuntap_open(&(eee.device), tuntap_dev_name, ip_addr, netmask, device_mac, mtu) < 0)
        return(-1);

    if(local_port > 0)
        traceEvent(TRACE_NORMAL, "Binding to local port %d", local_port);

    if(edge_init_twofish( &eee, (u_int8_t *)(encrypt_key), strlen(encrypt_key) ) < 0) return(-1);
    eee.sinfo.sock = open_socket(local_port, eee.sinfo.is_udp_socket, 0);
    if(eee.sinfo.sock < 0) return(-1);

    if( !(eee.sinfo.is_udp_socket) ) {
        int rc = connect_socket(eee.sinfo.sock, &(eee.supernode));

        if(rc == -1) {
            traceEvent(TRACE_WARNING, "Error while connecting to supernode\n");
            return(-1);
        }
    }

    update_registrations(&eee);

    traceEvent(TRACE_NORMAL, "");
    traceEvent(TRACE_NORMAL, "Ready");

    /* Main loop
     *
     * select() is used to wait for input on either the TAP fd or the UDP/TCP
     * socket. When input is present the data is read and processed by either
     * readFromIPSocket() or readFromTAPSocket()
     */

    while(1) {
        int rc, max_sock = 0;
        fd_set socket_mask;
        struct timeval wait_time;
        time_t nowTime;

        FD_ZERO(&socket_mask);
        FD_SET(eee.sinfo.sock, &socket_mask);

        wait_time.tv_sec = SOCKET_TIMEOUT_INTERVAL_SECS; wait_time.tv_usec = 0;

        rc = select(max_sock+1, &socket_mask, NULL, NULL, &wait_time);
        nowTime=time(NULL);

        if(rc > 0)
        {
            /* Any or all of the FDs could have input; check them all. */

            if(FD_ISSET(eee.sinfo.sock, &socket_mask))
            {
                /* Read a cooked socket from the internet socket. Writes on the TAP
                 * socket. */
                readFromIPSocket(&eee);
            }

        }

        update_registrations(&eee);

        numPurged =  purge_expired_registrations( &(eee.known_peers) );
        numPurged += purge_expired_registrations( &(eee.pending_peers) );
        if ( numPurged > 0 )
        {
            traceEvent( TRACE_NORMAL, "Peer removed: pending=%ld, operational=%ld",
                        peer_list_size( eee.pending_peers ), peer_list_size( eee.known_peers ) );
        }

        if ( ( nowTime - lastStatus ) > STATUS_UPDATE_INTERVAL )
        {
            lastStatus = nowTime;

            traceEvent( TRACE_NORMAL, "STATUS: pending=%ld, operational=%ld",
                        peer_list_size( eee.pending_peers ), peer_list_size( eee.known_peers ) );
        }
    } /* while */
#endif
}

- (void) disconnect
{
#if 0
    send_deregister( &eee, &(eee.supernode));

    closesocket(eee.sinfo.sock);
    tuntap_close(&(eee.device));

    edge_deinit( &eee );
#endif
}


- (void) awakeFromNib
{
    // create the NSStatusBar and set its length
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    // where are the bundle files?
    NSBundle *bundle = [NSBundle mainBundle];

    // allocate and load the images into the app
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_inactive" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"ptn_icon_active" ofType:@"png"]];

    // set the images in our NSStatusItem
    [statusItem setImage:statusImage];
    // [statusItem setAlternateImage:statusHighlightImage];

    // tells the nsstatusitem what menu to load
    [statusItem setMenu:statusMenu];
    // sets the tooltip for the item
    [statusItem setToolTip:@"Custom Menu Item"];
    // enable highlighting
    [statusItem setHighlightMode:YES];
}

- (void) dealloc
{
    // Release the 2 images
    [statusImage release];
    [statusHighlightImage release];
    [super dealloc];
}

@end
