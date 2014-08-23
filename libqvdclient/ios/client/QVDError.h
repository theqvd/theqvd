/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>
#import "QVDError.h"
#import "QVDClientWrapper.h"
#import "QVDXvncWrapperService.h"

@interface QVDError : NSObject

+ (void) errorAlert:(NSString *)title withMessage:(NSString *)message withUIViewController:(UIViewController *)uiviewController withWithSegue:(NSString *)segueName;
+ (void) errorAlert: (NSString *) title withMessage: (NSString *) message;
+(void) fatalAlert:(NSString *)title withMessage:(NSString *)message withUIViewController:(UIViewController *)uiviewController withWithSegue:(NSString *)segueName;
+ (void) fatalAlert: (NSString *) title withMessage: (NSString *) message;

@end
