/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import "QVDService.h"
#import "QVDClientWrapper.h"

@interface QVDVmListService : QVDService
@property (nonatomic) QVDClientWrapper *qvd;
@property (nonatomic) dispatch_queue_t vmlist_queue;
- (id) initWithStateUpdateDelegate:(id)delegate withQvdClientWrapper:(QVDClientWrapper *) qvd;
@end

