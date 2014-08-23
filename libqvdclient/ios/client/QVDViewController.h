/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <UIKit/UIKit.h>
#import "QVDParentUIViewController.h"

@interface QVDViewController : QVDParentUIViewController

@property (weak,nonatomic) IBOutlet UITextField *loginText;
@property (weak,nonatomic) IBOutlet UITextField *hostText;
@property (weak,nonatomic) IBOutlet UITextField *passText;
@property (weak,nonatomic) IBOutlet UIButton *connectButton;
@property (weak,nonatomic) IBOutlet UIButton *editConnectionButton;
@property (weak,nonatomic) IBOutlet UILabel *loginLabel;
@property (weak,nonatomic) IBOutlet UILabel *passLabel;
@property (weak,nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *restartLabel;
@property (weak, nonatomic) IBOutlet UISwitch *restartSwitch;

+ (UIViewController *) getViewController;
@end
