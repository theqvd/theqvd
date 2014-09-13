/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDVMConnectController.h"
#import "QVDViewServices.h"
#import "QVDError.h"

@interface QVDVMConnectController ()
@property (weak,nonatomic) QVDViewServices *viewServices;
@end

@implementation QVDVMConnectController
@synthesize viewServices, connectToVMLabel, connectToVMActivityIndicator;

// DISPLAY connecting to user@host and VM id: vm_id
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *labelText = [ [ NSString alloc ] initWithFormat:@"Connecting to VM %d for user %@@%@",  self.clientWrapper.selectedvmid, self.clientWrapper.login, self.clientWrapper.host];
    connectToVMLabel.text = labelText;
}
- (void)viewDidUnload
{
    connectToVMLabel = nil;
    connectToVMActivityIndicator = nil;
    [ super viewDidUnload ];
}
- (void)viewWillUnload {
    [ connectToVMActivityIndicator stopAnimating ];
    [ super viewWillUnload];
}
- (void)didReceiveMemoryWarning
{
    [ connectToVMActivityIndicator stopAnimating ];
    [super didReceiveMemoryWarning];
}
- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
    if (self.clientWrapper.restartVm) {
        NSLog(@"Restart of VM requested: %d", self.clientWrapper.selectedvmid);
        NSString *labelText = [ [ NSString alloc ] initWithFormat:@"Stopping VM %d for user %@@%@",  self.clientWrapper.selectedvmid, self.clientWrapper.login, self.clientWrapper.host];
        connectToVMLabel.text = labelText;
        [ self.clientWrapper stopVm ];
        labelText = [ [ NSString alloc ] initWithFormat:@"Connecting to VM %d for user %@@%@",  self.clientWrapper.selectedvmid, self.clientWrapper.login, self.clientWrapper.host];
        connectToVMLabel.text = labelText;
    }
    self.viewServices.segueName = @"segueFromVMConnectToShow";
    [ self.viewServices setController:self ];
    [ viewServices start ];
}
//- (void) viewWillAppear:(BOOL)animated {
//    [ super viewWillAppear:animated];
//}
- (void) viewWillDisappear:(BOOL)animated {
    [ connectToVMActivityIndicator stopAnimating ];
    [ super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
    [ connectToVMActivityIndicator stopAnimating ];
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

- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
    [ connectToVMActivityIndicator startAnimating ];
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"QVDVMConnectController: prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueFromVMConnectToShow"]) {
        NSLog(@"QVDVMConnectController: Going to Show");
        return;
    } else if ([segueId isEqualToString:@"backToMain"]) {
        NSLog(@"QVDVMConnectController: Going back to View, stopping VMServices");
        [ viewServices stop ];
        return;
    }
    // Segue unknown, this should not happen
    NSString *m = [[NSString alloc] initWithFormat:@"QVDVMConnectController: Oops, tech info: Unknown segue: %@", segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}
@end
