/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDXvncWrapperService.h"
#import "QVDError.h"
#include "qvdxvnc.h"
#include "unistd.h"
#include "stdio.h"
#include "websocket.h"
#include "tcpconnect.h"

#define MAXPATH 2048

@interface QVDXvncWrapperService ()
- (void) initQvdXvncWrapper;
@end

@implementation QVDXvncWrapperService
@synthesize basepath, fontpath, vncpasswdpath, vncpassarg, geometry, xvnc_queue;

const char *XVNC_QUEUE_NAME = "com.theqvd.ios.xvncqueue";
const char *XVNC_CHECK_QUEUE_NAME = "com.theqvd.ios.xvnccheckqueue";



// Singleton interface

static char fontpathchr[MAXPATH];
static char geometrychr[MAXPATH];
static char passwdargchr[MAXPATH];

- (NSString *) getBasePath {
    NSBundle* bundle = [NSBundle mainBundle];
    NSString *path = [bundle bundlePath];
    return path;
}

- (NSString *) getFontPath {
    NSString* fontpathbase = [NSString
                              stringWithFormat:@"%@/Library/files/usr/share/fonts",
                              self.basepath];
    NSString *path = [NSString
                      stringWithFormat:@"%@/misc,%@/100dpi,%@/75dpi,%@/Speedo,%@/Type1",
                      fontpathbase, fontpathbase, fontpathbase, fontpathbase, fontpathbase];
    return path;
}

- (NSString *) getGeometry {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width - NOVNC_TOP_FRAME_HEIGHT;
    //CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSString* geometry_v = [NSString stringWithFormat:@"%dx%d", (int)screenHeight, (int)screenWidth];
    return geometry_v;
}

- (NSString *) getPasswordPath {
    NSString* path = [NSString stringWithFormat:@"%@/Library/files/etc/vncpasswd",
                      self.basepath];
    return path;
}

- (NSString *) getPasswordArgPath {
    NSString* path = [NSString stringWithFormat:@"-PasswordFile=%@",
                      self.vncpasswdpath];
    return path;
}

- (void) initQvdXvncWrapper {
    self.basepath = [self getBasePath];
    self.fontpath = [self getFontPath];
    self.geometry = [self getGeometry];
    self.vncpasswdpath = [ self getPasswordPath];
    self.vncpassarg = [self getPasswordArgPath];
    self.xvnc_queue = dispatch_queue_create(XVNC_QUEUE_NAME, NULL);
    self.xvnc_check_queue = dispatch_queue_create(XVNC_CHECK_QUEUE_NAME, NULL);
    
    if ( [ self.fontpath length ] >= MAXPATH ||
            [ self.geometry length ] >= MAXPATH ||
            [ self.vncpassarg length ] >= MAXPATH) {
        [ QVDError fatalAlert:@"Internal Error" withMessage:@"Exceeded expected maximum fontpath/geometry/password chars. Aborting" ];
        abort();
    }
    strncpy(fontpathchr, [self.fontpath UTF8String], MAXPATH);
    strncpy(geometrychr, [self.geometry UTF8String], MAXPATH);
    strncpy(passwdargchr, [self.vncpassarg UTF8String], MAXPATH);
    
    NSLog(@"init: base path=%@, font path=%@, geometry=%@, passwd path=%@, pass arg=%@",
          self.basepath, self.fontpath, self.geometry, self.vncpasswdpath, self.vncpassarg);
    
}
- (id) init {
    self = [ super init ];
    [ self initQvdXvncWrapper ];
    return self;
}

-(id) initWithStateUpdateDelegate:(id)delegate {
    self = [ super initWithStateUpdateDelegate:delegate ];
    [ self initQvdXvncWrapper ];
    return self;
}

- (void) dealloc {
    NSLog(@"QVDXvncWrapperService dealloc");
    [ self stop ];
    // dispatch_release(self.xvnc_queue);
    // dispatch_release(self.xvnc_check_queue);
}

- (void) redirectStdinAndStout {
    return;
}

- (void)runStart
{
    signal(SIGPIPE, SIG_IGN);
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.xvnc_queue,^{
        char *myargv[] = {
            "Xvnc",
            ":0",
            "-br",
            "-geometry", geometrychr,
            "-pixelformat", "rgb888",
            "-pixdepths", "1","4","8","15","16","24","32",
            "+xinerama",
            "+render",
            "-CompareFB=0",
            "-desktop=QVD",
            passwdargchr,
            "-fp", fontpathchr
#ifdef QVD_IOS_DEBUG
            ,"-ac",
#endif
            // TODO should we allow remote connections?
        };
        int myargc=sizeof(myargv)/sizeof(char *);
        
        if (chdir([self.basepath UTF8String])<0){
            perror("chdir");
            NSLog(@"Error in chdir into %@", weakSelf.basepath);
        }else{
            NSLog(@"chdir into %@ ok", weakSelf.basepath);
        }
        dix_main(myargc, myargv, nil);
        
        NSLog(@"End of dix_main");
        if ([weakSelf getState] == stoppingStartRequested) {
            NSLog(@"Restart requested, after stop (state stoppingStartRequested), invoking start");
            [ weakSelf setState:stopped ];
            [ weakSelf start];
        } else {
            [ weakSelf setState:stopped ];
        }
    });
    
    NSLog(@"QVDXvncWrapperService: Start of xvnc check");
    dispatch_async(self.xvnc_check_queue, ^{
        int result = wait_for_tcpconnect(XVNC_VNCHOST, XVNC_VNCPORT, XVNC_STARTUP_TIMEOUT, 0);
        NSLog(@"QVDXvncWrapperService: End of xvnc check with error: %d", result);
        if (result != 0) {
            NSString *errorMessage = [ NSString stringWithFormat:@"Timeout of %d for starting the Xvnc Service",
                                      XVNC_STARTUP_TIMEOUT];
            [ weakSelf serviceError:errorMessage];
            [ weakSelf setState:failed ];
            [ weakSelf stop ];
        } else {
            if ([ weakSelf getState ] == startingStopRequested) {
                NSLog(@"QVDXvncWrapperService: End of xvnc check with success but stop requested");
                [ weakSelf setState:started ];
                [ weakSelf stop ];
            } else {
                NSLog(@"QVDXvncWrapperService: End of xvnc check with success. State started");
                [ weakSelf setState:started ];
            }
        }
        NSLog(@"End of xvnc check");
    });

}

- (BOOL) isRunning {
    NSLog(@"XvncWrapperService: isRunning");
    int result = wait_for_tcpconnect(XVNC_VNCHOST, XVNC_VNCPORT, 0, XVNC_CHECK_TIMEOUT);
    NSLog(@"WebProxyService: isRunning has result %d", result);
    return (result == 0);
}

- (void) runStop {
    [ super runStop ];
    NSLog(@"Invoking dix_main_end");
    dix_main_end();
    
}
@end
