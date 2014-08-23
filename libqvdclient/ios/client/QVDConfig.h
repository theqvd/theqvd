/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>

// TODO use proper Obj-C semantic
extern const char *WS_HOST;
extern const int WS_PORT;
extern const int WS_STARTUP_TIMEOUT;
extern const int WS_CHECK_TIMEOUT;
extern const char *XVNC_VNCHOST;
extern const char *XVNC_DISPLAY;
extern const char *XVNC_PASSWORD;
extern const int XVNC_VNCPORT;
extern const int XVNC_STARTUP_TIMEOUT;
extern const int XVNC_CHECK_TIMEOUT;
extern const int XVNC_XDISPLAYPORT;
extern const int NOVNC_TOP_FRAME_HEIGHT;
extern const int QVD_DEFAULT_PORT;
extern const int QVD_DEFAULT_WIDTH;
extern const int QVD_DEFAULT_HEIGHT;
extern const int QVD_DEFAULT_LINK_ITEM;
extern const int QVD_DEFAULT_PORT;
extern const BOOL QVD_USE_MOCK;
extern const BOOL QVD_DEFAULT_DEBUG;
extern const BOOL QVD_DEFAULT_FULLSCREEN;
extern const BOOL QVD_DEVELOP;
extern NSString *QVD_DEFAULT_LOGIN;
extern NSString *QVD_DEFAULT_PASS;
extern NSString *QVD_DEFAULT_HOST;
extern UIViewController *qvdViewController;

@interface QVDConfig : NSObject
@end

