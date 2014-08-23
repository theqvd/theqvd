/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDClientWrapper.h"
#import "QVDVmRepresentation.h"
#import "QVDXvncWrapperService.h"
#import "QVDXvncWrapperService.h"
#import "QVDConfig.h"

#include "qvdclient.h"
#include "qvdvm.h"
@interface QVDClientWrapper ()
@property (nonatomic) qvdclient *qvd;
@property (nonatomic) dispatch_queue_t connect_queue;
@property int connect_result;
@property BOOL mock_connection_established;

@end

@implementation QVDClientWrapper

static QVDClientWrapper *instance = nil;
@synthesize name, login, pass, host, port, listvm, selectedvmid, debug, mockConnection, fullscreen, width, height, linkitem, x509certfile, x509keyfile, usecertfiles, os, homedir, restartVm;
@synthesize qvd, connect_queue, connect_result, linkTypes, mock_connection_established;
@synthesize certificateExceptionHandler, connectionProgressHandler;


const char *DEFAULT_QUEUE_NAME  = "com.theqvd.ios.queue";
NSString * IOS_OS = @"ios";

// Singleton interface
+(QVDClientWrapper *)instance {
    @synchronized(self) {
        if (instance == nil) {
            NSLog(@"QVDClientWrapper: instance was nil, setting instance");
            instance = [ QVDClientWrapper new ];
        }
    }
    return instance;
}
+(void) setInstance:(QVDClientWrapper *)newInstance {
    NSLog(@"QVDClientWrapper: setInstance is called");
    instance = newInstance;
}

- (id) init {
    self = [ super init ];
    self.name = @"";
    self.login = @"";
    self.pass = @"";
    self.host = @"";
    self.port = QVD_DEFAULT_PORT;
    self.listvm = nil;
    self.qvd = NULL;
    self.selectedvmid = -1;
    self.debug = QVD_DEFAULT_DEBUG;
    self.fullscreen = QVD_DEFAULT_FULLSCREEN;
    self.width = QVD_DEFAULT_WIDTH;
    self.height = QVD_DEFAULT_HEIGHT;
    self.x509certfile = @"";
    self.x509keyfile = @"";
    self.usecertfiles = NO;
    self.connect_queue = dispatch_queue_create(DEFAULT_QUEUE_NAME, NULL);
    self.linkTypes = [[ NSArray alloc] initWithObjects: @"Local", @"ADSL", @"Modem", nil];
    self.linkitem = 1; // By default ADSL
    self.os = IOS_OS;
    self.mockConnection = QVD_USE_MOCK;
    self.mock_connection_established = FALSE;
    self.restartVm = FALSE;
    NSFileManager *fm = [ NSFileManager new];
    NSError *err = nil;
    NSURL * suppurl = [ fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
    if (err != nil) {
        NSLog(@"QVDClientWrapper: Error creating Application support directory %@", err);
        self.homedir = nil;
    } else {
        self.homedir = [ suppurl path ];
    }
    return self;
}
- (void) dealloc {
    // End all connections
//    dispatch_release(connect_queue);
    [ self freeResources ];
    return;
}
- (id) initWithUser: (NSString *) myuser password:(NSString *) mypassword host:(NSString *) myhost {
    self = [self init];
    if (self) {
        self.login = (myuser == nil) ? @"": myuser;
        self.pass = (nil == mypassword) ? @"": mypassword;
        self.host = (nil == myhost) ? @"" : myhost;
    }
    return self;
}
- (NSString *) lastError {
    NSString *e;
    if (qvd != NULL && qvd->error_buffer != NULL) {
        e = [[NSString alloc] initWithUTF8String:qvd->error_buffer];
    } else {
        e = @"";
    }
    return e;
    
}

- (NSString *) name {
    NSString *d = self->name;
    if ((!d || [ d isEqualToString:@""])
        && self.login && self.host &&
        (![self.login isEqualToString:@""]) &&
        (![self.host isEqualToString:@""])) {
        d = [[NSString alloc] initWithFormat:@"%@@%@", self.login, self.host];
        self.name = d;
    }
    return self->name; 
}

- (NSMutableArray *) convertVMlistIntoNSArray {
    int i;
    vmlist *vm_ptr;
    NSMutableArray *vms = nil;
    
    if (qvd->vmlist == NULL) {
        return nil;
   }
    vms = [[NSMutableArray alloc] initWithCapacity:qvd->numvms];
    for (vm_ptr = qvd->vmlist, i=0; i < qvd->numvms; ++i, vm_ptr = vm_ptr->next) {
        if (vm_ptr == NULL) {
            NSLog(@"QVDClientWrapper: Internal error converting vmlist in position %d, pointer is null and should not be", i);
            return nil;
        }
        vm *data = vm_ptr->data;
        if (data == NULL) {
            NSLog(@"QVDClientWrapper: Internal error converting vmlist in position %d, data pointer is null and should not be", i);
            return nil;
        }
        
        QVDVmRepresentation *vm = [[QVDVmRepresentation alloc] initWithId:data->id withName:data->name
                                                                withState:data->state withBlocked:data->blocked];
        [ vms addObject:vm];
    }
    return vms;
}

- (void) listOfVms {
    NSLog(@"getVmIds");
    if (login == nil || pass == nil || host == nil) {
        NSLog(@"QVDClientWrapper: Error user (%@) password (%@) or host is nil(%@) ", login, pass, host);
        return;
    }
    if (self.debug)
        qvd_set_debug();
    
    qvd=qvd_init([host UTF8String], self.port, [login UTF8String], [pass UTF8String]);
    
 
    NSLog(@"QVDClientWrapper: qvd_init %p with debug: %d", qvd, get_debug_level());
    
    if (self.certificateExceptionHandler == nil) {
        NSLog(@"QVDClientWrapper: listOfVms: certExceptionHandler is nil, disabling cert checks");
        qvd_set_no_cert_check(qvd);
    } else {
        NSLog(@"QVDClientWrapper: listOfVms: certExceptionHandler is non nil, enabling cert checks");
        qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);
    }

    if (self.connectionProgressHandler == nil) {
        NSLog(@"QVDClientWrapper: listOfVms: connectionProgressHandler is nil, disabling progress handler");
        qvd_set_progress_callback(qvd, NULL);
    } else {
        NSLog(@"QVDClientWrapper: listOfVms: connectionProgressHandler is non nil, enabling progress handler");
        qvd_set_progress_callback(qvd, progress_callback);
    }
    //qvd->userdata = (__bridge void *) self;
    if (self.fullscreen)
        qvd_set_fullscreen(qvd);
    
    NSString *geometry = [[NSString alloc] initWithFormat:@"%dx%d", self.width, self.height];
    qvd_set_geometry(qvd, geometry.UTF8String);

    qvd_set_os(qvd, self.os.UTF8String);

    if (self.homedir)
        qvd_set_home(qvd,self.homedir.UTF8String);
    qvd_set_display(qvd, XVNC_DISPLAY);
    
    NSLog(@"Disabling signal handling for curl");
    if (curl_easy_setopt(qvd->curl, CURLOPT_NOSIGNAL, 1) != CURLE_OK) {
        NSLog(@"Error setting CURLOPT_NOSIGNAL");
    }
    
    NSLog(@"QVDClientWrapper: calling qvd_list_of_vm");
    if (mockConnection) {
        QvdVmListAppendVm(qvd, qvd->vmlist, QvdVmNew(123, "testname123", "RUNNING", 0));
//        QvdVmListAppendVm(qvd, qvd->vmlist, QvdVmNew(124, "testname124", "RUNNING", 0));
        qvd->numvms = 1;
    } else {
        NSLog(@"Call qvd_list_of_vm %p curl %p", qvd, qvd->curl);
        qvd_list_of_vm(qvd);
    }
    // Might have press the cancel button
    if (qvd) {
        NSLog(@"QVDClientWrapper: Number of vms is: %d", qvd->numvms);
        self.listvm = [ self convertVMlistIntoNSArray];
    }
}

- (int) stopVm {
    NSLog(@"QVDClientWrapper: stopVm");
    if (qvd == NULL) {
        NSLog(@"QVDClientWrapper: stopVm: Error qvd pointer is NULL, returning -1");
        return -1;
    }
    if (mockConnection) {
        connect_result = 0;
        self.mock_connection_established = FALSE;
    } else {
        connect_result = qvd_stop_vm(qvd, selectedvmid);
    }
    NSLog(@"QVDClientWrapper: stopVm %d with qvd %p result was %d", selectedvmid, qvd, connect_result);
    return connect_result;
}

- (int) connectToVm {
    NSLog(@"QVDClientWrapper: connectToVM");
    if (qvd == NULL) {
        NSLog(@"QVDClientWrapper: connectToVm: Error qvd pointer is NULL, returning -1");
        return -1;
    }
    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p", selectedvmid, qvd);

    if (mockConnection) {
        connect_result = 0;
        self.mock_connection_established = TRUE;
        NSLog(@"QVDClientWrapper: connectToVm mock connection started");
        while (self.mock_connection_established) {
            sleep(5);
        }
        NSLog(@"QVDClientWrapper: connectToVm mock connection finished");
    } else {
        connect_result = qvd_connect_to_vm(qvd, selectedvmid);
    }
    
    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p result was %d", selectedvmid, qvd, connect_result);
    return connect_result;
}

- (void) freeResources {
    NSLog(@"QVDClientWrapper: freeResources: qvd_free");
    if (qvd != NULL) {
        qvd_free(qvd);
        qvd = NULL;
    }
    self.selectedvmid = -1;
    instance = nil;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"user:%@, pass: ..., host: %@, fullscreen=%d, widthxheight=%dx%d, debug=%d, link=%d[%@]", login, host, fullscreen, width, height, debug, linkitem, linkTypes[linkitem] ];
}


int accept_unknown_cert_callback(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data) {
    int result;
    NSString *pemstr, *pemdata;
    NSLog(@"QVDClientWrapper: accept_unknown_cert_callback (%s, %s)", cert_pem_str, cert_pem_data);
    pemstr = [ [ NSString alloc ] initWithUTF8String: cert_pem_str ];
    pemdata = [ [ NSString alloc ] initWithUTF8String: cert_pem_data ];
    QVDClientWrapper *qw = [ QVDClientWrapper instance ];
    id<QVDCertificateExceptionHandler> exceptionHandler = qw.certificateExceptionHandler;
    if (exceptionHandler == nil) {
        NSLog(@"QVDClientWrapper: accept_unknown_cert_callback: certificateExceptionHandler is nil, this should not happen. Accepting cert as fallback.");
        return 1;
    }
    result = [ exceptionHandler verifyCert: pemstr withPemData: pemdata ];
    return result;
}


//-(void) setCertificateExceptionHandler:(id<QVDCertificateExceptionHandler>) myCertExceptionHandler {
//    self.certificateExceptionHandler = myCertExceptionHandler;
//    if (myCertExceptionHandler == nil) {
//        NSLog(@"QVDClientWrapper: setCertificateExceptionHandler: certExceptionHandler is nil, disabling cert checks");
//        qvd_set_no_cert_check(qvd);
//        qvd->userdata = NULL;
//        return;
//    }
//    
//    NSLog(@"QVDClientWrapper: setCertificateExceptionHandler: certExceptionHandler is non nil, enabling cert checks");
//    qvd->userdata = (__bridge void *) self;
//    qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);
//}

int progress_callback(qvdclient *qvd, const char *message) {
    NSString *mymessage = [ [ NSString alloc ] initWithUTF8String: message ];
    QVDClientWrapper *qw = [ QVDClientWrapper instance ];
    id<QVDConnectionProgressHandler> progressHandler = qw.connectionProgressHandler;
    if (progressHandler == nil) {
        NSLog(@"QVDClientWrapper: progress_callback: connectionProgressHandler is nil, this should not happen disabling messages: %@", mymessage);
        return 1;
    }
    [ progressHandler connectionProgressMessageCallback:mymessage ];
    return 0;
}
- (void) setConnectionProgressHandler:(id<QVDConnectionProgressHandler>) myConnectionProgressHandler {
    // TODO fix progresshandler
//    self.connectionProgressHandler = myConnectionProgressHandler;
//    if (qvd == NULL) {
//        NSLog(@"QVDClientWrapper: setConnectionProgressHandler: qvd pointer is null, not enabling progressHandler, waiting for init");
//        return;
//    }
//    if (self.connectionProgressHandler == nil) {
//        NSLog(@"QVDClientWrapper: setConnectionProgressHandler: nil, disabling progress handler");
//        qvd_set_progress_callback(qvd, NULL);
//        return;
//    }
//    NSLog(@"QVDClientWrapper: setConnectionProgressHandler: non nil, enabling progress handler");
////    qvd->userdata = (__bridge void *) self;
//    qvd_set_progress_callback(qvd, progress_callback);
    return;
}

- (void) endConnection {
    NSLog(@"QVDClientWrapper: endConnection");
    if (qvd == NULL) {
        NSLog(@"QVDClientWrapper: endConnection: qvd pointer is null, not ending connection, waiting for init");
        return;
    }
    if (mockConnection) {
        self.mock_connection_established = FALSE;
        NSLog(@"QVDClientWrapper: endConnection for mock");
    } else {
        qvd_end_connection(qvd);
    }
}
@end
