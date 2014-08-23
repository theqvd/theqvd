/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDError.h"

@implementation QVDError


+ (void) errorAlert:(NSString *)title withMessage:(NSString *)message withUIViewController:(UIViewController *)uiviewController withWithSegue:(NSString *)segueName {
    NSLog(@"Error alert with nonlocalized title <%@> and text <%@>", title, message);
    NSString *ok = NSLocalizedString(@"ok", nil);
    NSString *localizedTitle = NSLocalizedString(title, nil);
    NSString *localizedMessage = NSLocalizedString(message, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:ok otherButtonTitles: nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
        NSLog(@"Error alert with title <%@> and text <%@>", localizedTitle, localizedMessage);
        if (uiviewController != nil && segueName != nil) {
            [ uiviewController performSegueWithIdentifier:segueName sender:uiviewController];
        }
    });

    
}

+ (void) errorAlert: (NSString *) title withMessage: (NSString *) message {
    [ QVDError errorAlert:title withMessage:message withUIViewController:nil withWithSegue:nil];
//    [ viewSer presentViewController:[QVDViewController getViewController] animated:YES completion:];
// TODO go to main window??    UIWindow * mainWindow = [UIApplication sharedApplication].windows.firstObject;
}



+(void) fatalAlert:(NSString *)title withMessage:(NSString *)message withUIViewController:(UIViewController *)uiviewController withWithSegue:(NSString *)segueName {
    [ self errorAlert:title withMessage:message withUIViewController:uiviewController withWithSegue:segueName];
    // TODO abort
    
}

+ (void) fatalAlert: (NSString *) title withMessage: (NSString *) message {
    [ QVDError fatalAlert:title withMessage:message withUIViewController:nil withWithSegue:nil];
}

@end
