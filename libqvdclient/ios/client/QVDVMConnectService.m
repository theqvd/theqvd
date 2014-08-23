/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDVMConnectService.h"

const char *QVD_VMCONNECT_QUEUE_NAME = "com.theqvd.vmconnect";

@implementation QVDVMConnectService

@synthesize qvd;

- (void) initQvdClientConnect {
    self.vmconnect_queue = dispatch_queue_create(QVD_VMCONNECT_QUEUE_NAME, NULL);
    self.qvd = [ QVDClientWrapper instance ];
}
- (id) init {
    self = [ super init ];
    [ self initQvdClientConnect ];
    return self;
}

- (id) initWithStateUpdateDelegate:(id)delegate {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdClientConnect ];
    return self;
}

- (id) initWithStateUpdateDelegate:(id)delegate withQvdClientWrapper:(QVDClientWrapper *)qvdInstance {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdClientConnect ];
    self.qvd = qvdInstance;
    return self;
}
- (void) dealloc {
    [ self stop ];
    self.qvd = nil;
    //dispatch_release(self.vmconnect_queue);
}

- (BOOL) isRunning {
    BOOL result;
    result = ([ self getState ] == started );
    NSLog(@"QVDVMConnectService: isRunning %d", result);
    return result;
}

- (void) runStart {
    dispatch_async(self.vmconnect_queue, ^{
        NSLog(@"QVDVMConnectService runStart");
        // We don't check the service
        self.qvd = [ QVDClientWrapper instance];
        // TODO delay the setState, better, modify libqvdclient
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ self setState:started ];
        //});
        [ self.qvd connectToVm ];
        NSLog(@"QVDVMConnectService: connectToVm has finished. set state to stopped");
        [ self setState:stopped ];
        [ self.qvd freeResources ];
        if ([self getState] == stoppingStartRequested) {
            NSLog(@"QVDVMConnectService Restart requested, after stop (state stoppingStartRequested), invoking start");
            [ self start];
        }
    });
//    __weak typeof(self) weakSelf = self;
    
//    dispatch_async(self.vmconnect_queue, ^{
//        NSLog(@"QVDVMConnectService runStart");
//        // We don't check the service
//        weakSelf.qvd = [ QVDClientWrapper instance];
//        // TODO delay the setState, better, modify libqvdclient
//        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [ weakSelf setState:started ];
//        //});
//        [ weakSelf.qvd connectToVm ];
//        NSLog(@"QVDVMConnectService: connectToVm has finished. set state to stopped");
//        [ weakSelf setState:stopped ];
//        [ weakSelf.qvd freeResources ];
//        if ([weakSelf getState] == stoppingStartRequested) {
//            NSLog(@"QVDVMConnectService Restart requested, after stop (state stoppingStartRequested), invoking start");
//            [ weakSelf start];
//        }
//    });
}

- (void) runStop {
    NSLog(@"QVDVMConnectService runStop");
    [ self.qvd endConnection ];
    // TODO after a timeout of 5 seconds stop curl...
    [ self setState:stopped];
}
@end
