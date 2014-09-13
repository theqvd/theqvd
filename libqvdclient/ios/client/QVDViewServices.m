/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDViewServices.h"
#import "QVDError.h"
#import "QVDXvncWrapperService.h"
#import "QVDWebProxyService.h"
#import "QVDVMConnectService.h"
#import "QVDParentUIViewController.h"
#import "QVDViewController.h"


@interface QVDViewServices()
@property (nonatomic,weak) QVDParentUIViewController *viewController;
@property (nonatomic, weak) QVDXvncWrapperService *xvncWrapper;
@property (nonatomic, weak) QVDWebProxyService *webProxy;
@property (nonatomic, weak) QVDVMConnectService *vmConnect;
@property (nonatomic) BOOL seguePerformed;
@end

@implementation QVDViewServices
@synthesize xvncWrapper, webProxy, vmConnect, segueName, viewController, seguePerformed;

- (void) initQVDViewServices {
    xvncWrapper = [ QVDXvncWrapperService instance ];
    webProxy = [ QVDWebProxyService instance ];
    vmConnect = [ QVDVMConnectService instance ];
    xvncWrapper.stateDelegate = self;
    webProxy.stateDelegate = self;
    vmConnect.stateDelegate = self;
    seguePerformed = NO;

}
- (id) init {
    self = [ super init ];
    [ self initQVDViewServices ];
    [ self setStatusUpdateDelegate:self ];
    return self;
}

- (id) initWithStateUpdateDelegate:(id)delegate {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQVDViewServices ];
    return self;
}

- (void) dealloc {
    self.xvncWrapper = nil;
    self.webProxy = nil;
    self.vmConnect = nil;
    self.viewController = nil;
}

- (void) runStart {
    [ self.xvncWrapper start ];
    [ self.webProxy start ];
    if ([ self.xvncWrapper getState ] == started) {
        [ self.vmConnect start ];
        [ self handleAllStarted ];
    }
}

- (void) runStop {
    [ self.vmConnect stop ];
    // Never stopping these
   // [ self.webProxy stop ];
   // [ self.xvncWrapper stop ];
}

- (void) didQVDServiceStateChanged:(id)service withState:(QVDServiceState) serviceState {
    NSLog(@"Handling state %d for class %@", serviceState, service);
    if ([service isKindOfClass:[QVDXvncWrapperService class]]) {
        [ self handleXvncServiceStates:serviceState ];
    } else if ([service isKindOfClass:[QVDWebProxyService class]]) {
        [ self handleWebProxyStates:serviceState ];
    } else if ([service isKindOfClass:[QVDVMConnectService class]]) {
        [ self handleVMConnectStates:serviceState ];
    } else if ([service isKindOfClass:[QVDViewServices class]]) {
        [ self handleQVDServiceStates:serviceState ];
    } else {
        NSLog(@"Unknown service obj: %@ [%@]", service, [[service class] description] );
        [ service serviceError:@"Internal error: Unknown service detected" ];
    }
}

- (BOOL) handleAllStarted {
    BOOL allstarted;
    // If viewServices is starting (we ae in VMConnectService controller and xvnc is started
    // Start also the vmConnect
    if (([ self getState] == starting || [ self getState ] == startingStopRequested) &&
        ([ self.xvncWrapper getState ] == started )) {
        [ self.vmConnect start ];
    }
    
    allstarted = (([ self.xvncWrapper getState ] == started) &&
               ([ self.webProxy getState ] == started) &&
               ([ self.vmConnect getState ] == started));
    NSLog(@"QVDViewServices: handleAllStarted: %d", allstarted);
    if (allstarted) {
        [ self setState:started ];
        if (segueName != nil && viewController != nil){
            NSLog(@"QVDViewService: handleAllstarted invoking segue: %@ for controller %@", segueName, viewController);
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //dispatch_async(dispatch_get_main_queue(), ^{
            NSString *controllerClass = [ [ viewController class ] description ];
            if (![ controllerClass isEqualToString:@"QVDVMConnectController"]) {
                NSLog(@"QVDViewService: Controller class is not QVDVMConnectController, not doing anything???: %@", self);
                return allstarted;
            }
            if (seguePerformed) {
                NSLog(@"QVDViewService: handleAllstarted segue already performed: %@. Skipping new segue", segueName);
                return allstarted;
            }
            [ viewController performDelayedSegueWithIdentifier:segueName];
            seguePerformed = YES;
            return allstarted;
                                //});
        }
        
        NSLog(@"QVDViewService: handleAllstarted segue or controller is nil segue %@ controller %@ not doing anything", segueName, viewController);
    }
    return allstarted;
}

- (BOOL) handleAllStopped {
    BOOL allstopped;

    // Keep xvncWrapper running, this does not support restart
    // Do not stop webProxy
    // if vmConnect is stopped then the global state is stopped
    if ([ self.xvncWrapper getState ] == stopped) {
        [ QVDError fatalAlert:@"Internal error" withMessage:@"Xvnc server was stopped, this should not happen" ];
    }
    //if ([ self.webProxy getState ] != stopped) [ self.webProxy stop ];
    if ([ self.vmConnect getState ] != stopped) [ self.vmConnect stop ];
    allstopped = ([ self.vmConnect getState ] == stopped);
    
    NSLog(@"QVDViewServices: allstopped: %d", allstopped);
    if (allstopped) {
        [ self setState:stopped ];
        // Reset seguePerformed
        self.seguePerformed = NO;
        if (viewController == nil) {
            NSLog(@"QVDViewServices: allstopped: viewController is nil no segue");
            return allstopped;
        }
        NSString *controllerClass = [ [ viewController class ] description ];
        NSLog(@"QVDViewServices: Controller class is %@", controllerClass);
        // Use presentViewController:animated:completion
        if ([ controllerClass isEqualToString:@"QVDViewController"]) {
            // No action already in ViewController
            return allstopped;
        }

//        [ viewController dismissViewControllerAnimated:YES completion:^{
//            [ viewController presentViewController:[QVDViewController getViewController] animated:YES completion:nil];
//        }];
        
        if ([ controllerClass isEqualToString:@"QVDVMConnectController"]) {
            [ viewController dismissViewControllerAnimated:YES  completion:^{
                [ viewController performDelayedSegueWithIdentifier:@"segueFromVMConnectToView" ];
            }];
        } else if ([ controllerClass isEqualToString:@"QVDShowVmController"]) {
            [ viewController dismissViewControllerAnimated:YES  completion:^{
                [ viewController performDelayedSegueWithIdentifier:@"segueShowToView"];
            }];
        } else if ([ controllerClass isEqualToString:@"QVDViewController"]) {
            // No action already in ViewController
            return allstopped;
        } else if ([ controllerClass isEqualToString:@"QVDEditViewController"]) {
            // No action
            return allstopped;
        } else if ([ controllerClass isEqualToString:@"QVDVMListController"]) {
            // No action
            return allstopped;
        } else if ([ controllerClass isEqualToString:@"QVDSelectVmController"]) {
            // No action
            return allstopped;
        } else {
            [ QVDError fatalAlert:@"Internal Error" withMessage:@"Unknown Controller class in QVDViewServices handleAllStopped"];
        }
    }
    return allstopped;
}

- (void) handleQVDServiceStates:(QVDServiceState) serviceState {
    
    switch (serviceState) {
        case starting:
            NSLog(@"QVDViewServices: QVDService state was starting, no action");
            return;
        case startingStopRequested:
            NSLog(@"QVDViewServices: QVDService state was startingStopRequested, no action available");
            return;
        case started:
            NSLog(@"QVDViewServices: QVDService state was started, no action");
            return;
        case stopping:
            NSLog(@"QVDViewServices: QVDService state was stopping, no action");
            return;
        case stoppingStartRequested:
            NSLog(@"QVDViewServices: QVDService state was stoppingStartRequired, no action");
            return;
        case stopped:
            NSLog(@"QVDViewServices: QVDService state was stopped, no action");
            return;
        case failed:
            NSLog(@"QVDViewServices: QVDService state was failed: invoking error");
            [ self serviceError:@"Error launching QVDService"];
            return;
        default:
            NSLog(@"QVDViewServices: QVDService state was unknown %d, internal error", serviceState);
            [ self serviceError:@"Internal error: There was an internal error starting services"];
            return;
    }
}


- (void) handleXvncServiceStates:(QVDServiceState) serviceState {
    
    switch (serviceState) {
        case starting:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was starting, no action");
            return;
        case startingStopRequested:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was startingStopRequested, no action available");
            return;
        case started:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was started, start QVDVMConnectService");
            // TODO see when vmConnect should be started
            [ self handleAllStarted ];
            return;
        case stopping:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was stopping, no action");
            return;
        case stoppingStartRequested:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was stoppingStartRequired, no action");
            return;
        case stopped:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was stopped, call handleAllStopped");
            [ self handleAllStopped ];
            return;
        case failed:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was failed: invoking error");
            [ self serviceError:@"Error launching X"];
            return;
        default:
            NSLog(@"QVDViewServices: QVDXvncWrapperService state was unknown %d, internal error", serviceState);
            [ self serviceError:@"Internal error: There was an internal error starting X"];
            return;
    }
}

- (void) handleWebProxyStates:(QVDServiceState) serviceState {
    switch (serviceState) {
        case starting:
            NSLog(@"QVDViewServices: QVDWebProxyService state was starting, no action");
            return;
        case startingStopRequested:
            NSLog(@"QVDViewServices: QVDWebProxyService state was startingStopRequested, no action available");
            return;
        case started:
            NSLog(@"QVDViewServices: QVDWebProxyService state was started, start QVDVMConnectService");
            [ self handleAllStarted ];
            return;
        case stopping:
            NSLog(@"QVDViewServices: QVDWebProxyService state was stopping, no action");
            return;
        case stoppingStartRequested:
            NSLog(@"QVDViewServices: QVDWebProxyService state was stoppingStartRequired, no action");
            return;
        case stopped:
            NSLog(@"QVDViewServices: QVDWebProxyService state was stopped, handleAllStopped");
            [ self handleAllStopped ];
            return;
        case failed:
            NSLog(@"QVDViewServices: QVDWebProxyService state was failed: invoking error");
            [ self serviceError:@"Error launching WebProxy"];
            return;
        default:
            NSLog(@"QVDViewServices: QVDWebProxyService state was unknown %d, internal error", serviceState);
            [ self serviceError:@"Internal error: There was an internal error starting WebProxy"];
            return;
    }
}

- (void) handleVMConnectStates:(QVDServiceState) serviceState {
    switch (serviceState) {
        case starting:
            NSLog(@"QVDViewServices: QVDVMConnectService state was starting, no action");
            return;
        case startingStopRequested:
            NSLog(@"QVDViewServices: QVDVMConnectService state was startingStopRequested, no action available");
            return;
        case started:
            NSLog(@"QVDViewServices: QVDVMConnectService state was started, start QVDVMConnectService");
            [ self handleAllStarted ];
            return;
        case stopping:
            NSLog(@"QVDViewServices: QVDVMConnectService state was stopping, no action");
            return;
        case stoppingStartRequested:
            NSLog(@"QVDViewServices: QVDVMConnectService state was stoppingStartRequired, no action");
            return;
        case stopped:
            NSLog(@"QVDViewServices: QVDVMConnectService state was stopped, stop the rest of services");
            [ self handleAllStopped ];
            return;
        case failed:
            NSLog(@"QVDViewServices: QVDVMConnectService state was failed: invoking error");
            [ self serviceError:@"Error in QVD VM Connect"];
            return;
        default:
            NSLog(@"QVDViewServices: QVDVMConnectService state was unknown %d, internal error", serviceState);
            [ self serviceError:@"Internal error: There was an internal error in QVD VM Connect"];
            return;
    }
}

- (void) setController:(id)v {
    NSLog(@"QVDViewServices: setController %@", v);
    self.viewController = v;
}

@end

