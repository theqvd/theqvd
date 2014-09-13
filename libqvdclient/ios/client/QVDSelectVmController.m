/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDSelectVmController.h"
#import "QVDVmRepresentation.h"
#import "QVDViewServices.h"
#import "QVDError.h"

@interface QVDSelectVmController()
@property (weak,nonatomic) QVDClientWrapper *clientWrapper;
@end

@implementation QVDSelectVmController
@synthesize clientWrapper;

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [ super viewDidUnload ];
}
- (void)viewWillUnload {
    [ super viewWillUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated];
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

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    QVDVmRepresentation *vm = (QVDVmRepresentation *) [ self.clientWrapper.listvm objectAtIndex:row];
    self.clientWrapper.selectedvmid = vm.id;
    NSLog(@"QVDVMSelectVmController: pickerview calling QVDConnection with vmid %d", self.clientWrapper.selectedvmid);

    [ self performDelayedSegueWithIdentifier:@"segueFromSelectVMToVMConnect" ];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSLog(@"QVDVMSelectVmController: numberOfComponentsInPickerView");
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"QVDVMSelectVmController: pickerView:numberOfRowsInComponent");
    NSLog(@"QVDVMSelectVmController: pickerView:numberOfRowsInComponent: %lu, %@", (unsigned long)self.clientWrapper.listvm.count, self.clientWrapper);
    return self.clientWrapper.listvm.count;
}


- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    QVDVmRepresentation *vm = [ self.clientWrapper.listvm objectAtIndex:row ];
    NSString *s = [ vm description ];
    return s;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"QVDVMSelectVmController: prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueFromSelectVMToVMConnect"]) {        
        return;
    } else if ([segueId isEqualToString:@"backToMain"]) {
        [ self.clientWrapper freeResources ];
        return;
    }
    // Segue unknown, this should not happen
    NSString *m = [[NSString alloc] initWithFormat:@"QVDVMSelectVmController: Oops, tech info: Unknown segue: %@", segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}

@end
