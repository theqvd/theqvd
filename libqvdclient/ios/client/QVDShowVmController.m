/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDShowVmController.h"
#import "QVDError.h"
#import "QVDWebProxyService.h"
#import "QVDXvncWrapperService.h"


@implementation QVDShowVmController
@synthesize novncwebview;


- (void)viewWillUnload {
    [ super viewWillUnload];
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"QVDShowVmController viewDidApper");
    [ super viewDidAppear:animated];
//    [ self loadNoVnc ];
}

- (void) viewWillDisappear:(BOOL)animated {
    [ super viewWillDisappear:animated];
    if ([novncwebview isLoading]) {
        NSLog(@"QVDShowVmController: viewWillDisappear: novncwebview is loading. Stopping");
        [ novncwebview stopLoading ];
    }
    [ novncwebview setDelegate:nil];
}
- (void) viewDidDisappear:(BOOL)animated {
    [ super viewDidDisappear:animated];
}

- (void) viewDidLoad  {
    [ super viewDidLoad];
    [ self loadNoVnc ];
    NSLog(@"QVDShowVmController: viewDidLoad end");
}

- (void) viewWillAppear:(BOOL)animated  {
    [ super viewWillAppear:animated];
    NSLog(@"QVDShowVmController: viewWillAppear clientwrapper is %@", self.clientWrapper);
    NSString *m = [[ NSString alloc ] initWithFormat:@"vmid is %d. Error: %@", self.clientWrapper.selectedvmid, self.clientWrapper.lastError];
    NSLog(@"QVDShowVmController: The testrunningvm.text is %@", m);
    // Cancel segues for services, we are already in show
    self.viewServices.segueName = nil;
    //[ self.viewServices setController:nil ];
    NSLog(@"QVDShowVmController: viewWillAppear end");
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    NSLog(@"QVDShowVmController: prepareForSegue %@ : %@", segueId, sender);
    if ([segueId isEqualToString:@"backToMain"]) {
        return;
    }
    
    // Segue unknown, this should not happen
    NSString *m = [[NSString alloc] initWithFormat:@"QVDShowVmController: Oops, tech info: Unknown segue: %@", segueId];
    [ QVDError fatalAlert:@"internalErrorTitle" withMessage:m];
}

// TODO Use NSLocalNotification
- (void) connectionProgressMessageCallback:(NSString *) message {
    NSLog(@"QVDShowVmController: Progress message: %@", message);
}
- (void)viewDidUnload {
    [self setNovncwebview:nil];
    [ super viewDidUnload ];
}


- (void)didReceiveMemoryWarning {
    [self setNovncwebview:nil];
    [ super didReceiveMemoryWarning ];
}

- (void) loadNoVnc {
    NSLog(@"QVDShowVmController: Launch noVNC");
    NSLog(@"QVDShowVmController: Start set delegate");
    [ novncwebview setDelegate:self];
    NSLog(@"QVDShowVmController: End set delegate");

//    novncwebview.contentMode = UIViewContentModeScaleAspectFill;
//    novncwebview.scalesPageToFit = YES;
//    novncwebview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
//    [novncwebview setKeyboardDisplayRequiresUserAction:NO];
    NSString *novnc_path = [[ NSBundle mainBundle] pathForResource:@"vnc_qvd" ofType:@"html" inDirectory:@"noVNC"];
    NSString *loglevel = (self.clientWrapper.debug) ? @"debug" : @"warn";
    NSString *novnc_url = [ NSString stringWithFormat:@"file://localhost%@?autoconnect=true&logging=%@&host=%s&port=%d&encrypt=false&true_color=1&password=%s", novnc_path, loglevel, WS_HOST, WS_PORT, XVNC_PASSWORD ];
    NSLog(@"novnc_url %@", novnc_url);
    NSURL *url = [NSURL URLWithString:novnc_url];
    // TODO use
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSLog(@"QVDShowVmController: Start web request");
    [novncwebview loadRequest:req];
    NSLog(@"QVDShowVmController: End web request");
    novncwebview.hidden = YES;
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//    });
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"QVDShowVmController: webViewDidFinishLoad");
//    [ self loadNoVnc];
    webView.hidden = NO;
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"QVDShowVmController: didFailLoadWithError %@", error);
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"QVDShowVmController: webViewDidStartLoad");
    
//    NSLog(@"novncwiew %d", novncwebview.scalesPageToFit);
//    CGRect newBounds = novncwebview.bounds;
//    NSLog(@"novncwiew old size %f x %f", newBounds.size.width ,newBounds.size.height);
//    
//    //    newBounds.size.height = novncwebview.scrollView.contentSize.height;
//    //    newBounds.size.width = novncwebview.scrollView.contentSize.width;
//    //    NSLog(@"novncwiew new size %f x %f", newBounds.size.width ,newBounds.size.height);
//    //    novncwebview.bounds = newBounds;
//    novncwebview.scrollView.scrollEnabled = NO;
//    novncwebview.scrollView.bounces = NO;
//    novncwebview.keyboardDisplayRequiresUserAction=YES;
//    NSLog(@"QVDShowVmController: webViewDidStartLoad end");
}

- (void) stopQvd {
    NSLog(@"QVDShowVmController: Sending end connection to QVD window");
    [ self.clientWrapper endConnection ];
    if ([novncwebview isLoading]) {
        NSLog(@"QVDShowVmController: novncwebview is loading");
        [ novncwebview stopLoading ];
    }
    // TODO review ShowToView...
//    [ self dismissViewControllerAnimated:YES completion:^{
//        [ self performSegueWithIdentifier:@"backToMain" sender:self];
//    }];
    [ self performDelayedSegueWithIdentifier:@"backToMain" ];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString ];
    if ([url hasPrefix:@"ios"]) {
        [ self webToNativeCall:url ];
        return NO;
    }
    NSLog(@"webView delegate invoked for url %@", url);
    return YES;
}

- (void) webToNativeCall:(NSString *)url {
    if ([ url hasPrefix:@"ios-log:"]) {
        NSArray *stringArray = [ url componentsSeparatedByString:@":%23IOS%23" ];
        if (stringArray.count == 2) {
            NSLog(@"UIWebView console: %@", [ stringArray objectAtIndex:1]);
        } else {
            NSLog(@"UIWebView console: Error in the String format should be ios-log:#IOS# but is %@", url);
        }
        
        return;
    }
    NSLog(@"QVDShowVmController: webToNativeCall: Invoking url %@", url);
    if ([ url isEqualToString:@"ios:disconnect"]) {
        [ self stopQvd ];
        return;
    }

    NSLog(@"QVDShowVmController: webToNativeCall: Unknown url invoked %@", url);
}
@end
