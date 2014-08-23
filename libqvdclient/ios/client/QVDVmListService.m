/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDVmListService.h"
#import "QVDClientWrapper.h"



@interface QVDVmListService ()
@property BOOL running;
@end
@implementation QVDVmListService

@synthesize qvd, running;

const char *QVD_VMLIST_QUEUE_NAME = "com.theqvd.vmlist";

- (void) initQvdClientList {
    self.running = false;
    self.vmlist_queue = dispatch_queue_create(QVD_VMLIST_QUEUE_NAME, NULL);
    self.qvd = [QVDClientWrapper instance];
}
- (id) init {
    self = [ super init ];
    [ self initQvdClientList ];
    return self;
}

- (id) initWithStateUpdateDelegate:(id)delegate {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdClientList ];
    return self;
}

- (id) initWithStateUpdateDelegate:(id)delegate withQvdClientWrapper:(QVDClientWrapper *)qvdInstance {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdClientList ];
    self.qvd = qvdInstance;
    return self;
}

- (void) dealloc {
    [ self stop ];
    self.qvd = nil;
    //dispatch_release(self.vmlist_queue);
}

- (BOOL) isRunning {
    NSLog(@"QVDClientVmList: isRunning of vmlist %d", running);
    return running;
}

- (void) runStart {
    [ super runStart ];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.vmlist_queue, ^{
        // Minimal starting state ignore startingStopRequested
        [ weakSelf setState:started ];
        [ weakSelf.qvd listOfVms ];
        [ weakSelf setState:stopped ];
        NSLog(@"End of QVD vmList");
    });
}

- (void) runStop {
    // Does not do anything, currently there is no way to stop a /vm/list request
}

@end
