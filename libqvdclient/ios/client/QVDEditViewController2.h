/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDParentUIViewController.h"

@interface QVDEditViewController2 : QVDParentUIViewController

@property (weak, nonatomic) IBOutlet UILabel *heightwidthLabel;
@property (weak, nonatomic) IBOutlet UITextField *heightText;
@property (weak, nonatomic) IBOutlet UITextField *widthText;
@property (weak, nonatomic) IBOutlet UILabel *fullscreenLabel;
@property (weak, nonatomic) IBOutlet UISwitch *fullScreenSwitch;
@property (weak, nonatomic) IBOutlet UILabel *certfileLabel;
@property (weak, nonatomic) IBOutlet UITextField *certfileText;
@property (weak, nonatomic) IBOutlet UILabel *certkeyLabel;
@property (weak, nonatomic) IBOutlet UITextField *certkeyText;
@property (weak, nonatomic) IBOutlet UILabel *usekeyLabel;
@property (weak, nonatomic) IBOutlet UISwitch *usekeySwitch;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;

@end
