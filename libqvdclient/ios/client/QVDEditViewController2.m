/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDEditViewController2.h"
#import "QVDError.h"

@interface QVDEditViewController2 ()

@end

@implementation QVDEditViewController2

@synthesize heightwidthLabel, heightText, widthText, fullscreenLabel, fullScreenSwitch, certfileLabel, certfileText, certkeyLabel, certkeyText, usekeyLabel, usekeySwitch, debugLabel, debugSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    heightText.placeholder = NSLocalizedString(@"height", nil);
    widthText.placeholder = NSLocalizedString(@"width", nil);
    fullscreenLabel.text = NSLocalizedString(@"fullscreen", nil);
    heightwidthLabel.text = NSLocalizedString(@"widthheight", nil);
    certfileLabel.text = NSLocalizedString(@"X509 cert", nil);
    certkeyLabel.text = NSLocalizedString(@"x509 key", nil);
    usekeyLabel.text = NSLocalizedString(@"Use X509 certs", nil);
    debugLabel.text = NSLocalizedString(@"debug", nil);
}


// Before Save status in case of memory warning
- (void)didReceiveMemoryWarning {
    [ self updateClientWrapperFromFields ];
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    heightwidthLabel = nil;
    heightText = nil;
    widthText = nil;
    fullscreenLabel = nil;
    fullScreenSwitch = nil;
    certfileLabel = nil;
    certfileText = nil;
    certkeyLabel = nil;
    certkeyText = nil;
    usekeyLabel = nil;
    usekeySwitch = nil;
    debugLabel = nil;
    debugSwitch = nil;
    
    [super viewDidUnload];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) updateFieldsFromClientWrapper {
    debugSwitch.on = self.clientWrapper.debug;
    widthText.text = [[ NSString alloc ] initWithFormat:@"%d", self.clientWrapper.width ];
    heightText.text = [[ NSString alloc ] initWithFormat:@"%d", self.clientWrapper.height ];
    fullScreenSwitch.on = self.clientWrapper.fullscreen;
    // TODO add x509 certificates
}

- (void) updateClientWrapperFromFields {
    if (!self.clientWrapper) {
        NSLog(@"QVDEditViewController: Connection was nil, initializing");
        QVDClientWrapper * c = [ QVDClientWrapper new ];
        self.clientWrapper = c;
    }

    self.clientWrapper.debug = debugSwitch.on;
    self.clientWrapper.width = widthText.text.intValue;
    self.clientWrapper.height = heightText.text.intValue;
    self.clientWrapper.fullscreen = fullScreenSwitch.on;
    // TODO add x509 certificates
}

// Invoked before segue to Main View Controller
// Used to update the clientWrapper from the existing fields
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"segueEdit2ToView" ] || [ segueId isEqualToString:@"segueEdit2ToEdit"]) {
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



- (void) viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated];
    
    self.clientWrapper = [ QVDClientWrapper instance ];
    NSLog(@"connection in edit controller is %@", self.clientWrapper);
    [ self updateFieldsFromClientWrapper ];
}


@end
