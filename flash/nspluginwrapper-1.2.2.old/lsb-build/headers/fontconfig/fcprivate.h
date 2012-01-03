#ifndef _FONTCONFIG_FCPRIVATE_H_
#define _FONTCONFIG_FCPRIVATE_H_


#ifdef __cplusplus
extern "C" {
#endif


#define FcObjectSetVapBuild(__ret__,__first__,__va__)	 \
	{ FcObjectSet *__os__; const char *__ob__; __ret__ = 0; __os__ = \
	FcObjectSetCreate (); if (!__os__) goto _FcObjectSetVapBuild_bail0; \
	__ob__ = __first__; while (__ob__) { if (!FcObjectSetAdd (__os__, \
	__ob__)) goto _FcObjectSetVapBuild_bail1; __ob__ = va_arg (__va__, \
	const char *); } __ret__ = __os__; _FcObjectSetVapBuild_bail1: if \
	(!__ret__ && __os__) FcObjectSetDestroy (__os__); \
	_FcObjectSetVapBuild_bail0: ; }
#define FcPatternVapBuild(result,orig,va)	 \
	{ FcPattern *__p__ = (orig); const char *__o__; FcValue __v__; if \
	(!__p__) { __p__ = FcPatternCreate (); if (!__p__) goto \
	_FcPatternVapBuild_bail0; } for (;;) { __o__ = va_arg (va, const char \
	*); if (!__o__) break; __v__.type = va_arg (va, FcType); switch \
	(__v__.type) { case FcTypeVoid: goto _FcPatternVapBuild_bail1; case \
	FcTypeInteger: __v__.u.i = va_arg (va, int); break; case FcTypeDouble: \
	__v__.u.d = va_arg (va, double); break; case FcTypeString: __v__.u.s = \
	va_arg (va, FcChar8 *); break; case FcTypeBool: __v__.u.b = va_arg \
	(va, FcBool); break; case FcTypeMatrix: __v__.u.m = va_arg (va, \
	FcMatrix *); break; case FcTypeCharSet: __v__.u.c = va_arg (va, \
	FcCharSet *); break; case FcTypeFTFace: __v__.u.f = va_arg (va, \
	FT_Face); break; case FcTypeLangSet: __v__.u.l = va_arg (va, FcLangSet \
	*); break; } if (!FcPatternAdd (__p__, __o__, __v__, FcTrue)) goto \
	_FcPatternVapBuild_bail1; } result = __p__; goto \
	_FcPatternVapBuild_return; _FcPatternVapBuild_bail1: if (!orig) \
	FcPatternDestroy (__p__); _FcPatternVapBuild_bail0: result = (void*)0; \
	_FcPatternVapBuild_return: ; }



#ifdef __cplusplus
}
#endif
#endif
