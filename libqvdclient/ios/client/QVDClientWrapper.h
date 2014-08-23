/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>



@protocol QVDCertificateExceptionHandler
- (int) verifyCert: (NSString *) pemStr withPemData: (NSString*) pemData;
@end

@protocol QVDConnectionProgressHandler
- (void) connectionProgressMessageCallback:(NSString *) message;
@end

@interface QVDClientWrapper : NSObject



@property (nonatomic) NSString *name, *login, *pass, *host, *x509certfile, *x509keyfile, *homedir, *os;
@property (nonatomic) int port, selectedvmid, width, height, linkitem;
@property (nonatomic) BOOL debug, fullscreen, usecertfiles, mockConnection;
@property (nonatomic) NSArray *listvm;
@property (nonatomic) NSArray *linkTypes;
@property (nonatomic) id<QVDCertificateExceptionHandler> certificateExceptionHandler;
@property (nonatomic) id<QVDConnectionProgressHandler> connectionProgressHandler;
@property (nonatomic) BOOL restartVm;
+ (QVDClientWrapper *) instance;
+ (void) setInstance:(QVDClientWrapper *) instance;
- (id) initWithUser: (NSString *) user password:(NSString *)password host:(NSString *) host;
- (void) listOfVms;
- (int) connectToVm;
- (int) stopVm;
- (NSString *) lastError;
- (void) freeResources;
- (void) endConnection;
@end
