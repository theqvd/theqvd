/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDViewController.h"
#import "QVDXvncWrapperService.h"
#import "QVDWebProxyService.h"
#import "QVDError.h"
#import "QVDClientWrapper.h"
#import "QVDViewServices.h"
#import "QVDVMConnectService.h"

@interface QVDViewController ()

@end

UIViewController *uiviewcontroller = nil;
@implementation QVDViewController

@synthesize loginText, passText, hostText, connectButton, editConnectionButton, loginLabel, passLabel, hostLabel, restartLabel, restartSwitch;

// TODO check websocket failure and disconnect
// TODO global Add save properties
// TODO check two concurrent xvnc running, port conflict and app ends
// TODO check when VM is in state stopping and connection happens. Press cancel in vm connect
// TODO add checkbox for restart VM
// TODO Review all QVDError outputs
// TODO REview case of novnc output when it does not connect (connect/disconnect button)
// Add about button (in settings?)

+ (UIViewController*) getViewController {
    return uiviewcontroller;
}

- (void)viewWillUnload {
    [ super viewWillUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
}
- (void) viewWillDisappear:(BOOL)animated {
    [ super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
    [ super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    [ super viewDidLoad ];
    loginText.placeholder = NSLocalizedString(@"login", nil);
    passText.placeholder = NSLocalizedString(@"password", nil);
    hostText.placeholder = NSLocalizedString(@"host", nil);
    loginLabel.text = NSLocalizedString(@"login", nil);
    passLabel.text = NSLocalizedString(@"password", nil);
    hostLabel.text = NSLocalizedString(@"host", nil);
    restartLabel.text = NSLocalizedString(@"Restart vm", nil);
    connectButton.titleLabel.text = NSLocalizedString(@"connect", nil);
    [ connectButton setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateNormal ];
    [ connectButton setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateDisabled ];
    [ connectButton setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateHighlighted ];
    [ connectButton setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateSelected ];
    [ connectButton setTitle:NSLocalizedString(@"connect", nil) forState:UIControlStateReserved ];
    editConnectionButton.titleLabel.text = NSLocalizedString(@"edit", nil);
    [ editConnectionButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal ];
    [ editConnectionButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateDisabled ];
    [ editConnectionButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateHighlighted ];
    [ editConnectionButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateSelected ];
    [ editConnectionButton setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateReserved ];
    uiviewcontroller = self;
}

// Release any retained subviews of the main view.
- (void)viewDidUnload
{
    [ self.clientWrapper setCertificateExceptionHandler:nil ];
    editConnectionButton = nil;
    connectButton = nil;
    loginText = nil;
    passText = nil;
    hostText = nil;
    loginLabel = nil;
    passLabel = nil;
    hostLabel = nil;
    restartLabel = nil;
    restartSwitch = nil;
    [ super viewDidUnload ];
}

- (void) updateFieldsFromClientWrapper {
    NSLog(@"QVDViewController: updateFieldsFromClientWrapper");
    loginText.text = self.clientWrapper.login;
    passText.text = self.clientWrapper.pass;
    hostText.text = self.clientWrapper.host;
    restartSwitch.on = self.clientWrapper.restartVm;
}

- (void) updateClientWrapperFromFields {
    self.clientWrapper.restartVm = restartSwitch.on;
    if (QVD_DEVELOP && [ loginText.text isEqualToString:@""]) {
        self.clientWrapper.login = QVD_DEFAULT_LOGIN;
        self.clientWrapper.pass = QVD_DEFAULT_PASS;
        self.clientWrapper.host = QVD_DEFAULT_HOST;
    } else {
        self.clientWrapper.login = (loginText.text) ? loginText.text : @"";
        self.clientWrapper.pass = (passText.text) ? passText.text : @"";
        self.clientWrapper.host = (hostText.text) ? hostText.text : @"";
    }
}



// Invoked before going to another controller
// In the case of going to the edit view we update the clientWrapper fields
// like login, so that they appear correctly in the edit view
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"QVDViewController: prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueViewToEdit"]) {        
        [self updateClientWrapperFromFields];
        return;
    } else if ([segueId isEqualToString:@"segueFromViewToVMList"]) {
        [self updateClientWrapperFromFields];
        return;
    }
    // Segue unknown, this should not happen
    NSString *m = [[NSString alloc] initWithFormat:@"QVDViewController: Oops, tech info: Unknown segue: %@", segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}

- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
    
    self.clientWrapper = [ QVDClientWrapper instance ];
    NSLog(@"QVDViewController: connection in view controller is %@", self.clientWrapper);
    [ self updateFieldsFromClientWrapper ];
}

- (IBAction)pressConnect:(id)sender {
    NSLog(@"QVDViewController: pressConnect");
    [self updateClientWrapperFromFields];
    QVDVMConnectService *vmConnect = [ QVDVMConnectService instance ];
    QVDVmListService *vmList = [ QVDVmListService instance ];
    if ([vmList getState] != stopped) {
        NSLog(@"QVDViewController: vmList state different from stopped: %d", [vmList getState]);
        [ QVDError errorAlert:@"Temporary error" withMessage:@"Tearing down old connections please try again later (vmlist running)"];
        return;
    }
    if ([vmConnect getState] != stopped) {
        NSLog(@"QVDViewController: vmConnect state different from stopped: %d", [vmConnect getState]);
        [ QVDError errorAlert:@"Temporary error" withMessage:@"Tearing down old connections please try again later (vmconnect running)"];
        [ vmConnect stop ];
        return;
    }
    [ self performSegueWithIdentifier:@"segueFromViewToVMList" sender:self];
    
}


@end
