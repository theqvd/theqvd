/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDEditViewController.h"
#import "QVDViewController.h"
#import "QVDClientWrapper.h"
#import "QVDError.h"
#include "qvdclient.h"

@implementation QVDEditViewController

@synthesize nameText,loginText, passText, hostText, portText, nameLabel, loginLabel, passLabel, hostLabel, selectLinkPicker, linkLabel;

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//}
//- (void)viewDidUnload
//{
//    [ super viewDidUnload ];
//}
//- (void)viewWillUnload {
//    [ super viewWillUnload];
//}
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//}
- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
}
//- (void) viewWillAppear:(BOOL)animated {
//    [ super viewWillAppear:animated];
//}
- (void) viewWillDisappear:(BOOL)animated {
    [ super viewWillDisappear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
    [ super viewDidDisappear:animated];
}

// Update the fields from clientWrapper after loading it
- (void)viewDidLoad
{
    [ super viewDidLoad ];
    self.selectLinkPicker.frame = CGRectMake(333,471,113,80);
    nameText.placeholder = NSLocalizedString(@"name", nil);
    nameLabel.text = NSLocalizedString(@"name", nil);
    loginText.placeholder = NSLocalizedString(@"login", nil);
    loginLabel.text = NSLocalizedString(@"login", nil);
    passText.placeholder = NSLocalizedString(@"password", nil);
    passLabel.text = NSLocalizedString(@"password", nil);
    hostText.placeholder = NSLocalizedString(@"host", nil);
    hostLabel.text = NSLocalizedString(@"host", nil);
    portText.placeholder = NSLocalizedString(@"port", nil);
    linkLabel.text = NSLocalizedString(@"link", nil);
}

- (void) updateFieldsFromClientWrapper {

    nameText.text = self.clientWrapper.name;
    loginText.text = self.clientWrapper.login;
    passText.text = self.clientWrapper.pass;
    hostText.text = self.clientWrapper.host;
    portText.text = [[ NSString alloc ] initWithFormat:@"%d", self.clientWrapper.port];
    NSLog(@"QVDEditViewController: The selected link item is %d", self.clientWrapper.linkitem);
    [ self.selectLinkPicker selectRow:self.clientWrapper.linkitem inComponent:0 animated:YES];
}

- (void) updateClientWrapperFromFields {
    if (!self.clientWrapper) {
        NSLog(@"QVDEditViewController: Connection was nil, initializing");
        QVDClientWrapper * c = [ QVDClientWrapper new ];
        self.clientWrapper = c;
    }
    self.clientWrapper.name = nameText.text;
    self.clientWrapper.login = loginText.text;
    self.clientWrapper.pass = passText.text;
    self.clientWrapper.host = hostText.text;
    self.clientWrapper.port = portText.text.intValue;
    if (1 > self.clientWrapper.port || self.clientWrapper.port > 65535) {
        NSString *port = [ [ NSString alloc ] initWithFormat:@"%d", QVD_DEFAULT_PORT];
        portText.text = port;
        self.clientWrapper.port = QVD_DEFAULT_PORT;
        [ QVDError errorAlert:@"Invalid port" withMessage:@"Invalid port number, resetting to default" ];
        return;
    }

}

// Invoked before segue to Main View Controller
// Used to update the clientWrapper from the existing fields
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueEditToView"] || [segueId isEqualToString:@"segueEditToEdit2"]) {
        [ self updateClientWrapperFromFields ];
        return;
    }
    
    // Is not segueEditToView
    NSString *m = [[NSString alloc] initWithFormat:@"Oops, tech info: Unknown segue: %@", 
                   segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}

// Before unloading the view
- (void)viewWillUnload {
    [ self updateClientWrapperFromFields ];
    [super viewWillUnload];
}

// Before Save status in case of memory warning
- (void)didReceiveMemoryWarning {
    [ self updateClientWrapperFromFields ];
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    self.nameText = nil;
    self.loginText = nil;
    self.passText = nil;
    self.hostText = nil;
    self.portText = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
    
    self.clientWrapper = [ QVDClientWrapper instance ];
    NSLog(@"connection in edit controller is %@", self.clientWrapper);
    [ self updateFieldsFromClientWrapper ];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.clientWrapper.linkitem = (int)row;
    NSLog(@"pickerview selected link item is %ld", (long)row);
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSLog(@"numberOfComponentsInPickerView");
    return 1;
}


- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"pickerView:numberOfRowsInComponent: %lu", (unsigned long)self.clientWrapper.linkTypes.count);
    return self.clientWrapper.linkTypes.count;
}


- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *s = self.clientWrapper.linkTypes[row];
    return s;
}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return 24;
//}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    return 0;
//}

@end
