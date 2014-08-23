/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDWebProxyService.h"
#import "QVDXvncWrapperService.h"
#include "websocket.h"
#include "tcpconnect.h"

const char *WS_QUEUE_NAME = "com.theqvd.ios.websockifyqueue";
const char *WS_CHECK_QUEUE_NAME = "com.theqvd.ios.wscheckqueue";

@interface QVDWebProxyService ()
- (void) initQvdWebProxy;
@property (nonatomic) BOOL running;
@end

@implementation QVDWebProxyService

@synthesize websockify_queue, wscheck_queue, running;

- (void) initQvdWebProxy {
    self.websockify_queue = dispatch_queue_create(WS_QUEUE_NAME, NULL);
    self.wscheck_queue = dispatch_queue_create(WS_CHECK_QUEUE_NAME, NULL);
}

- (id) init {
    self = [ super init ];
    [ self initQvdWebProxy ];
    return self;
}

- (id)initWithStateUpdateDelegate: (id) delegate {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdWebProxy ];
    return self;
}

- (void) dealloc {
    [ self stop ];
    //dispatch_release(self.websockify_queue);
    //dispatch_release(self.wscheck_queue);
}

- (BOOL) isRunning {
    NSLog(@"WebProxyService: Start of websockify isRunning");
    int result = wait_for_tcpconnect(WS_HOST, WS_PORT, 0, WS_CHECK_TIMEOUT);
    NSLog(@"WebProxyService: isRunning has result %d", result);
    return (result == 0);
}

- (void) runStart {
    [ super runStart ];
    int debug = QVD_DEFAULT_DEBUG ? 1 : 0;
    dispatch_async(self.websockify_queue, ^{
        int result = websockify(debug, WS_HOST, WS_PORT, XVNC_VNCHOST, XVNC_VNCPORT);
        NSLog(@"End of websockify with result %d", result);
        if (result != 0) {
            [ self setState: failed ];
            [ self stop ];
        } else {

            // Set state to stopped unless stoppingStartRequested state
            if ([self getState] == stoppingStartRequested) {
                NSLog(@"WebProxyService: Stop requested after start, (state startingStopRequested), invoking stop");
                [ self setState:stopped ];
                [ self start ];
            } else {
                NSLog(@"WebProxyService: websockify has ended");
                [ self setState:stopped ];
            }
        }
    });
    
    NSLog(@"WebProxyService: Start of websockify check");
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.wscheck_queue, ^{
        int result = wait_for_tcpconnect(WS_HOST, WS_PORT, WS_STARTUP_TIMEOUT, 0);
        NSLog(@"WebProxyService: End of websockify check with error: %d", result);
        if (result != 0) {
            NSString *errorMessage = [ NSString stringWithFormat:@"Timeout of %d for starting the WebsocketProxy Service",
                                      WS_STARTUP_TIMEOUT];
            [ weakSelf serviceError:errorMessage];
            [ weakSelf setState:failed ];
            [ weakSelf stop ];
        } else {
            if ([ weakSelf getState ] == startingStopRequested) {
                NSLog(@"WebProxyService: End of websockify check with success but stop requested");
                [ weakSelf setState:started ];
                [ weakSelf stop ];
            } else {
                NSLog(@"WebProxyService: End of websockify check with success");
                [ weakSelf setState:started ];
            }
        }
        NSLog(@"End of websockify check");
    });
}

- (void) runStop {
    NSLog(@"WebProxyService: runStop");
    websockify_stop();
}

@end