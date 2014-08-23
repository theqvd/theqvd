/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

// X: Xvnc
// ws: WebSocket proxy
// nx: QVD NX connection
// ui: UIWebViewSocket
//
// Here should go the table

#import <Foundation/Foundation.h>
typedef enum {
    starting,
    startingStopRequested,
    started,
    stopping,
    stoppingStartRequested,
    stopped,
    failed
} QVDServiceState;


@protocol QVDServiceStateUpdate
- (void) didQVDServiceStateChanged:(id)service withState:(QVDServiceState) serviceState;
@end

@interface QVDService : NSObject
@property (nonatomic,weak) id<QVDServiceStateUpdate> stateDelegate;
+ (id) instance;
+ (void) setInstance:(id) instance;
- (id)initWithStateUpdateDelegate: (id) delegate;
- (void) setStatusUpdateDelegate: (id) delegate;
- (BOOL) isRunning;
- (void) runStart;
- (void) runStop;
- (void) start;
- (void) stop;
- (QVDServiceState) getState;
- (void) setState:(QVDServiceState)newState;
- (void) serviceError:(NSString *)message;
@end


