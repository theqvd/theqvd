/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#import <Foundation/Foundation.h>

@interface QVDVmRepresentation : NSObject {
    NSString *name, *state;
    int id, blocked;
}

@property (nonatomic) int id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *state;
@property (nonatomic) int blocked;

- (id) init;
- (id) initWithId: (int) id withName:(const char *) name withState: (const char *) state withBlocked: (int) blocked;
@end
