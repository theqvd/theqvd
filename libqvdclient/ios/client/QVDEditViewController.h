/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>
#import "QVDParentUIViewController.h"
#import "QVDError.h"

@interface QVDEditViewController : QVDParentUIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak,nonatomic) IBOutlet UITextField *nameText;
@property (weak,nonatomic) IBOutlet UITextField *loginText;
@property (weak,nonatomic) IBOutlet UITextField *passText;
@property (weak,nonatomic) IBOutlet UITextField *hostText;
@property (weak,nonatomic) IBOutlet UITextField *portText;
@property (weak,nonatomic) IBOutlet UILabel *nameLabel;
@property (weak,nonatomic) IBOutlet UILabel *loginLabel;
@property (weak,nonatomic) IBOutlet UILabel *passLabel;
@property (weak,nonatomic) IBOutlet UILabel *hostLabel;
@property (weak,nonatomic) IBOutlet UIPickerView *selectLinkPicker;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;


@end
