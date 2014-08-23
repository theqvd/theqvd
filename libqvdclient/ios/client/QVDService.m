/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDService.h"

@interface QVDService ()
@property (nonatomic) QVDServiceState state;
@end

@implementation QVDService
static NSMutableDictionary *instances = nil; // Keys are the subclasses and values the different instances
@synthesize stateDelegate, state;

// Singleton interface
//static QVDService *instance = nil;
+(id)instance {
    NSString *classname = [ self description ];
    QVDService *instance = nil;
    @synchronized(self) {
        if (instances == nil) {
            NSLog(@"Instances was nil initializing NSMutableDictionary");
            instances = [ NSMutableDictionary dictionary ];
        }
        instance = [instances objectForKey:classname];
        if (instance == nil) {
            NSLog(@"%@ instance was nil, setting instance", classname);
            instance = [ self new ];
            [ self setInstance:instance];
        }
    }
    return instance;
}
+(void) setInstance:(id)newInstance {
    NSString *classname = [ self description ];
    NSLog(@"%@ setInstance is called", classname);
    if (instances == nil) {
        NSLog(@"Instances was nil initializing NSMutableDictionary");
        instances = [ NSMutableDictionary dictionary ];
    }
    [ instances setObject:newInstance forKey:classname ];
}

- (id) init {
    state = stopped;
    return self;
}

- (void) setStatusUpdateDelegate:(id)delegate {
    self.stateDelegate = delegate;
}
- (id) initWithStateUpdateDelegate:(id)delegate {
    state = stopped;
    [ self setStatusUpdateDelegate:delegate ];
    return self;
}

- (void) dealloc {
    state = stopped;
    stateDelegate = nil;
}

- (BOOL) isRunning {
    NSLog(@"QVDservice::isStarted for class %@", [self description]);
    // Should this be virtual method? It doesn't make sense for QVDService
    return false;
}
- (void) start {
    NSString *classname = [ [ self class ] description];
    NSString *errorMessage;
    NSLog(@"QVDservice:start for class %@", classname);
    switch ([self getState]) {
        case stopping:
            NSLog(@"QVDservice %@: invoking start from stopping. Setting stoppingStartRequested", classname);
            [ self setState:stoppingStartRequested ];
            break;
        case startingStopRequested:
            NSLog(@"QVDservice %@: invoking start from startingStopRequested. Setting starting", classname);
            [ self setState:starting];
            break;
        case stopped:
            NSLog(@"QVDservice %@: invoking start from stopped. runStart", classname);
            [ self setState:starting];
            [ self runStart ];
            break;
        case started:
            NSLog(@"QVDservice %@: invoking start from started. No action", classname);
            break;
        case starting:
            NSLog(@"QVDservice %@: invoking start from starting. No action", classname);
            break;
        case stoppingStartRequested:
            NSLog(@"QVDservice %@: invoking start from stoppingStartRequested. No action", classname);
            break;
        case failed:
            NSLog(@"QVDservice %@: invoking stop from failed", classname);
            [ self stop ];
            break;
        default:
            errorMessage = [ NSString stringWithFormat:@"QVDservice %@:Unknown state for service", classname];
            [ self serviceError:errorMessage ];
            abort();
    }
}

- (void) stop {
    NSString *classname = [ [ self class ] description];
    NSString *errorMessage;
    NSLog(@"QVDservice %@:stop invoked", classname);
    switch ([self getState]) {
        case stopping:
            NSLog(@"QVDservice %@: invoking stop from stopping. No action", classname);
            break;
        case startingStopRequested:
            NSLog(@"QVDservice %@: invoking stop from startingStopRequested. No action", classname);
            break;
        case stopped:
            NSLog(@"QVDservice %@: invoking stop from stopped. No action", classname);
            break;
        case started:
            NSLog(@"QVDservice %@: invoking stop from started. invoking runStop", classname);
            [ self setState:stopping ];
            [ self runStop ];
            break;
        case starting:
            NSLog(@"QVDservice %@: invoking stop from starting. Set state startingStopRequested", classname);
            [ self setState:startingStopRequested ];
            break;
        case stoppingStartRequested:
            NSLog(@"QVDservice %@: invoking stop from stoppingStartRequested. set status to stopping", classname);
            [ self setState:stopping ];
            break;
        case failed:
            NSLog(@"QVDservice %@: invoking stop from failed. runStop invoked", classname);
            [ self runStop ];
            break;
        default:
            errorMessage = [ NSString stringWithFormat:@"QVDservice %@:Unknown state for service", classname ];
            [ self serviceError:errorMessage ];
            abort();
    }

}

- (void) runStart {
   NSLog(@"QVDservice %@:runStart", [ [ self class ] description]);
}
- (void) runStop {
   NSLog(@"QVDservice %@:runStop", [ [ self class ] description]);
}

- (QVDServiceState) getState {
    return state;
}
- (void) setState:(QVDServiceState)newState {
    state=newState;
    if (stateDelegate != nil) {
        [ stateDelegate didQVDServiceStateChanged:self withState:state];
    }

}

- (void) serviceError:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = [ NSString stringWithFormat:@"%@ Service Error", [[ weakSelf class ] description] ];
        NSString *m = [ NSString stringWithFormat:@"%@ Error: %@", [[ weakSelf class ] description], message ];
        NSLog(@"serviceError %@: %@", [ [weakSelf class] description], m);
        UIAlertView *alert = [ [ UIAlertView alloc ] initWithTitle:title message:m delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
        [alert show];
    });
}

@end
