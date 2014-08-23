/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDConfig.h"

const char *WS_HOST = "127.0.0.1";
const int WS_PORT = 5800;
const int WS_STARTUP_TIMEOUT = 10;
const int WS_CHECK_TIMEOUT = 20000; // 20 ms
const char *XVNC_VNCHOST = "127.0.0.1";
const char *XVNC_DISPLAY = "127.0.0.1:0";
const char *XVNC_PASSWORD = "ben1to";
const int XVNC_VNCPORT = 5900;
const int XVNC_STARTUP_TIMEOUT = 15;
const int XVNC_XDISPLAYPORT = 5900;
const int XVNC_CHECK_TIMEOUT = 20000;
const int NOVNC_TOP_FRAME_HEIGHT = 36;
const int QVD_DEFAULT_WIDTH = 1024;
const int QVD_DEFAULT_HEIGHT = 768;
const int QVD_DEFAULT_LINK_ITEM = 1;
const int QVD_DEFAULT_PORT = 8443;
const BOOL QVD_DEFAULT_DEBUG = YES;
const BOOL QVD_USE_MOCK = NO;
const BOOL QVD_DEFAULT_FULLSCREEN = YES;
#ifdef QVD_IOS_DEBUG
const BOOL QVD_DEVELOP = YES; // Only for development
NSString *QVD_DEFAULT_LOGIN = @"appledevprogram@qindel.com";
NSString *QVD_DEFAULT_PASS = @"applepass";
NSString *QVD_DEFAULT_HOST = @"demo.theqvd.com";
#else
const BOOL QVD_DEVELOP = NO;
NSString *QVD_DEFAULT_LOGIN = @"";
NSString *QVD_DEFAULT_PASS = @"";
NSString *QVD_DEFAULT_HOST = @"";
#endif

UIViewController *qvdViewController = nil;
@implementation QVDConfig

@end
