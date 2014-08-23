/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */
#import <UIKit/UIKit.h>
#import "QVDClientWrapper.h"
#import "QVDViewServices.h"
#import "QVDVmListService.h"
#import "QVDConfig.h"

@interface QVDParentUIViewController : UIViewController

@property (nonatomic) QVDClientWrapper *clientWrapper;
@property (nonatomic) QVDViewServices *viewServices;

- (void) performDelayedSegueWithIdentifier:(NSString *)identifier;

@end
