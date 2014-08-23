/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>
#import "QVDService.h"
#import "QVDConfig.h"



@interface QVDWebProxyService : QVDService
@property (nonatomic) dispatch_queue_t websockify_queue, wscheck_queue;
@end
