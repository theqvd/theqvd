/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */
#import "QVDVmRepresentation.h"

@implementation QVDVmRepresentation
@synthesize id,name,state,blocked;



- (id) init {
    self = [super init];
    return self;
}

- (id) initWithId: (int) myid withName:(const char *) myname withState: (const char *) mystate withBlocked: (int) myblocked {
    self = [ self init ];
    self.id = myid;
    NSString *n = [[NSString alloc] initWithUTF8String:myname];
    self.name = n;
    NSString *s = [[NSString alloc] initWithUTF8String:mystate];
    self.state = s;
    self.blocked = myblocked;
    return self;
}

- (NSString *) description {
    NSString *d = [[ NSString alloc] initWithFormat:@"%@(%d) - %@",
                   name, id, state
                   ];
    return d;
}

@end
