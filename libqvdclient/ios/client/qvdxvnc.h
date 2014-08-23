/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

/*
 * This prototypes the dispatch.c module (except for functions declared in
 * global headers), plus related dispatch procedures from devices.c, events.c,
 * extension.c, property.c. 
 */

#ifndef DIX_MAIN_H
#define DIX_MAIN_H 1

#define DE_TERMINATE 2
extern char dispatchException;
extern char isItTimeToYield;

#define dix_main_end() dispatchException=DE_TERMINATE; isItTimeToYield=1;

int dix_main(int argc, char *argv[], char *envp[]);

#endif /* DIX_MAIN_H */
