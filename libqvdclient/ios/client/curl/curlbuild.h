//
//  curlbuild.h
//  Includes curlbuild-32.h or curlbuild-64.h depending on
//  the macro __SIZE_WIDTH__
//
//  Created by nito on 03/07/14.
//
//

#ifndef client_curlbuild_h
#define client_curlbuild_h

#ifndef __SIZE_WIDTH__
#error "__SIZE_WIDTH__ is not defined by the compiler"
#endif

#if __SIZE_WIDTH__ == 32
#include "curlbuild-32.h"
#endif

#if __SIZE_WIDTH__ == 64
#include "curlbuild-64.h"
#endif


#endif
