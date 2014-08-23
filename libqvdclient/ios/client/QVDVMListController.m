/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDVMListController.h"
#import "QVDVmListService.h"
#import "QVDVmRepresentation.h"
#import "QVDError.h"

@interface QVDVMListController ()
@property (nonatomic) NSInteger buttonClicked;
@property (nonatomic) QVDVmListService *vmlistServices;
@end

@implementation QVDVMListController

@synthesize buttonClicked, vmlistServices, vmlistlabel, vmlistActivityIndicator;

// TODO update message based on qvdprogress
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    vmlistlabel = nil;
    vmlistActivityIndicator = nil;
    [ super viewDidUnload ];
}
- (void)viewWillUnload {
    [ vmlistActivityIndicator stopAnimating ];
    [ super viewWillUnload];
}
- (void)didReceiveMemoryWarning
{
    [ vmlistActivityIndicator stopAnimating ];
    [super didReceiveMemoryWarning];
}
//- (void) viewDidAppear:(BOOL)animated {
//    [ super viewDidAppear:animated];
//}
- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
    NSString *labelText = [ [ NSString alloc ] initWithFormat:@"Loading list of VMs for user %@@%@", self.clientWrapper.login, self.clientWrapper.host ];
    vmlistlabel.text = labelText;
    [ vmlistActivityIndicator startAnimating ];

}
- (void) viewWillDisappear:(BOOL)animated {
    [ vmlistActivityIndicator stopAnimating ];
    [ super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
    [ vmlistActivityIndicator stopAnimating ];
    [ super viewDidDisappear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
    self.clientWrapper = [ QVDClientWrapper instance ];
    // TODO X509
    // [ self.clientWrapper setCertificateExceptionHandler:self ];
    // TODO progressHandler if debug
    // Set the progressHandler and maintain user informed -> label or perhaps something else..
    [ self.clientWrapper setCertificateExceptionHandler:nil ];
    NSLog(@"QVDVMListController: clientWrapper is: %@", self.clientWrapper);
    self.vmlistServices = [ QVDVmListService instance ];
    [ self.vmlistServices setStatusUpdateDelegate:self ];
    [ self.vmlistServices setQvd:self.clientWrapper ];
    [ self.vmlistServices start ];
    // Go now to the delegate method didQVDServiceStateChanged
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"QVDVMListController: prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueFromVMListToSelectVM"]) {
        return;
    } else if ([segueId isEqualToString:@"segueFromVMListToVMConnect"]) {
        return;
    } else if ([segueId isEqualToString:@"segueFromVMListToView"]) {
        // Ignore any results from vm list setting delegate to nil
        [ self.vmlistServices setStatusUpdateDelegate:nil ];
        [ self.vmlistServices stop ];
        // VM list might still be running, do not free resources
        return;
    }
    // Segue unknown, this should not happen
    NSString *m = [[NSString alloc] initWithFormat:@"QVDVMListController: Oops, tech info: Unknown segue: %@", segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}

- (int) verifyCert: (NSString *) pemStr withPemData: (NSString*) pemData {
    NSLog(@"QVDVMListController: verifyCert: %@", pemStr);
    NSString *accept = NSLocalizedString(@"accept", nil);
    NSString *no = NSLocalizedString(@"no", nil);
    NSString *localizedTitle = NSLocalizedString(@"certificateAlert", nil);
    self.buttonClicked = -1;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:pemStr delegate:self cancelButtonTitle:accept otherButtonTitles: no, nil];
    [alert show];
    [self waitForButtonClicked];
    int result = (self.buttonClicked == 0) ? 1 : 0;
    return result;
}

// A bit ugly waiting for the result, TODO implement a callback...
- (NSInteger) waitForButtonClicked {
    NSDate *shortInterval;
    while (self.buttonClicked < 0) {
        shortInterval = [[ NSDate alloc ] initWithTimeIntervalSinceNow:0.2 ];
        [[ NSRunLoop currentRunLoop ] runUntilDate:shortInterval ] ;
    }
    return self.buttonClicked;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.buttonClicked=buttonIndex;
    return;
}


- (void) didQVDServiceStateChanged:(id)service withState:(QVDServiceState)serviceState {
    if (service != self.vmlistServices) {
        NSLog(@"QVDVMListController: The service <%@> is different from the vmlistservice <%@> for state %d", service, self.vmlistServices, serviceState);
        [ QVDError fatalAlert:@"Internal Error" withMessage:@"In controller QVDViewController an internal error was detected"];
        return;
    }
    switch (serviceState) {
        case starting:
            NSLog(@"QVDVMListController: VMlist state was starting, disable button");
            return;
        case startingStopRequested:
            NSLog(@"QVDVMListController: VMlist state was startingStopRequested, no action available");
            return;
        case started:
            NSLog(@"QVDVMListController: VMlist state was started, no action, we need to wait for stopped and result");
            return;
        case stopping:
            NSLog(@"QVDVMListController: VMlist state was stopping, no action");
            return;
        case stoppingStartRequested:
            NSLog(@"QVDVMListController: VMlist state was stoppingStartRequired, no action");
            return;
        case stopped:
            NSLog(@"QVDVMListController: VMlist state was stopped, checking for VM list");
            break;
        case failed:
            NSLog(@"QVDVMListController: VMlist state was failed, invoking error");
            [ QVDError errorAlert:@"Error connecting to QVD" withMessage:@"There was an error connecting to QVD"];
            return;
        default:
            NSLog(@"QVDVMListController: VMlist state was unknown %d, internal error", serviceState);
            [ QVDError fatalAlert:@"Internal error" withMessage:@"There was an internal error connecting to QVD"];
    }
    
    
    NSLog(@"QVDVMListController: clientWrapper after listOfVms is: %@", self.clientWrapper);
    
    if (!self.clientWrapper.listvm || self.clientWrapper.listvm.count == 0) {
        NSString *localizedTitle = NSLocalizedString(@"vmlistError", nil);
        NSString *m = [[NSString alloc] initWithFormat:@"Error: %@", self.clientWrapper.lastError];
        // Start over and free resources
        [ QVDError errorAlert:localizedTitle withMessage:m];
        [ self performDelayedSegueWithIdentifier:@"segueFromVMListToView" ];
        return;
    }
    
    if (self.clientWrapper.listvm.count == 1) {
        NSLog(@"QVDVMListController: List of vms has only one vm. selecting that VM: %@", self.clientWrapper.listvm );
        QVDVmRepresentation *vm = (QVDVmRepresentation *) [ self.clientWrapper.listvm objectAtIndex:0];
        self.clientWrapper.selectedvmid = vm.id;
        NSLog(@"QVDVMListController: calling connect with vmid %d", self.clientWrapper.selectedvmid);

        [ self performDelayedSegueWithIdentifier:@"segueFromVMListToVMConnect" ];

        return;
    }
    
    // Select VM
    [ self performDelayedSegueWithIdentifier:@"segueFromVMListToSelectVM" ];
}


@end
