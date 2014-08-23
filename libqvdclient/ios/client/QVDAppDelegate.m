/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDAppDelegate.h"
#import "QVDViewServices.h"
#import "QVDXvncWrapperService.h"
#import "QVDWebProxyService.h"
#import "QVDConfig.h"
#import "QVDError.h"
#include "tcpconnect.h"



@implementation QVDAppDelegate

@synthesize window = _window;


// TODO: Check for notifications when application is in foreground
// launchOptions key UIApplicationLaunchOptionsLocalNotificationKey with value
// UILocalNotification, send Alert
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"QVDAppDelegate: didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
    application.statusBarHidden = YES;
    int result = wait_for_tcpconnect(WS_HOST, WS_PORT, 0, 20000);
    NSLog(@"didFinishLaunchingWithOptions: End of websockify check with result: %d", result);
    if (result == 0) {
        [ QVDError errorAlert:@"Error socket in use" withMessage:@"There is another application listening on TCP port 5800. You need to stop that to get QVD running." ];
        return YES;
    }
    result = wait_for_tcpconnect(XVNC_VNCHOST, XVNC_VNCPORT, 0, 20000);
    NSLog(@"didFinishLaunchingWithOptions: End of xvnc check with result: %d", result);
    if (result == 0) {
        [ QVDError errorAlert:@"Error socket in use" withMessage:@"There is another application listening on TCP port 5900. You need to stop that to get QVD running." ];
        return YES;
    }
    result = wait_for_tcpconnect(XVNC_VNCHOST, XVNC_XDISPLAYPORT, 0, 20000);
    NSLog(@"didFinishLaunchingWithOptions: End of xvnc for port VNC check with result: %d", result);
    if (result == 0) {
        [ QVDError errorAlert:@"Error socket in use" withMessage:@"There is another application listening on TCP port 6000. You need to stop that to get QVD running." ];
        return YES;
    }
    // Start in the background the xvnc and the webproxy
    QVDXvncWrapperService *x = [ QVDXvncWrapperService instance ];
    [ x start ];
    QVDWebProxyService *w = [ QVDWebProxyService instance ];
    [ w start ];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"QVDAppDelegate: applicationWillResignActive");
}

// TODO: See implications with the connect method QVDClientWrapper
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"QVDAppDelegate: applicationDidEnterBackground");
}


// TODO: See implications with the connect method QVDClientWrapper
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"QVDAppDelegate: applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"QVDAppDelegate: applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"QVDAppDelegate: applicationWillTerminate");
    [ [ QVDViewServices instance ] stop ];
    [ [ QVDXvncWrapperService instance ]  stop ];
    [ [ QVDWebProxyService  instance ] stop ];
}


// TODO: Check for notifications when application is in foreground
// Send same alert as above
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"QVDAppDelegate: didReceiveLocalNotification");
}




@end
