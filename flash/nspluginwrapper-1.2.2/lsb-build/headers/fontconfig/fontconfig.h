#ifndef _FONTCONFIG_FONTCONFIG_H_
#define _FONTCONFIG_FONTCONFIG_H_

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif


#define _FCFUNCPROTOBEGIN
#define _FCFUNCPROTOEND
#define FC_USER_CACHE_FILE	".fonts.cache-"FC_CACHE_VERSION
#define FC_DIR_CACHE_FILE	"fonts.cache-"FC_CACHE_VERSION
#define FcIsUpper(c)	((0101 <= (c) && (c) <= 0132))
#define FcIsLower(c)	((0141 <= (c) && (c) <= 0172))
#define FC_CHARSET_DONE	((FcChar32) -1)
#define FC_VERSION	((FC_MAJOR * 10000) + (FC_MINOR * 100) + (FC_REVISION))
#define FcMatrixInit(m)	((m)->xx = (m)->yy = 1, (m)->xy = (m)->yx = 0)
#define FC_CHARSET_MAP_SIZE	(256/32)
#define FcToLower(c)	(FcIsUpper(c) ? (c) - 0101 + 0141 : (c))
#define FC_HINT_NONE	0
#define FC_PROPORTIONAL	0
#define FC_RGBA_UNKNOWN	0
#define FC_SLANT_ROMAN	0
#define FC_WEIGHT_THIN	0
#define FcFalse	0
#define FC_CACHE_VERSION	"1"
#define FC_HINT_SLIGHT	1
#define FC_RGBA_RGB	1
#define FcTrue	1
#define FC_MONO	100
#define FC_SLANT_ITALIC	100
#define FC_WEIGHT_MEDIUM	100
#define FC_WIDTH_NORMAL	100
#define FC_CHARCELL	110
#define FC_SLANT_OBLIQUE	110
#define FC_WIDTH_SEMIEXPANDED	113
#define FC_WIDTH_EXPANDED	125
#define FC_WIDTH_EXTRAEXPANDED	150
#define FC_WEIGHT_DEMIBOLD	180
#define FC_HINT_MEDIUM	2
#define FC_MAJOR	2
#define FC_REVISION	2
#define FC_RGBA_BGR	2
#define FC_WEIGHT_BOLD	200
#define FC_WIDTH_ULTRAEXPANDED	200
#define FC_WEIGHT_EXTRABOLD	205
#define FC_WEIGHT_BLACK	210
#define FC_HINT_FULL	3
#define FC_MINOR	3
#define FC_RGBA_VRGB	3
#define FC_RGBA_VBGR	4
#define FC_WEIGHT_EXTRALIGHT	40
#define FC_RGBA_NONE	5
#define FC_WEIGHT_LIGHT	50
#define FC_WIDTH_ULTRACONDENSED	50
#define FC_UTF8_MAX_LEN	6
#define FC_WIDTH_EXTRACONDENSED	63
#define FC_WEIGHT_BOOK	75
#define FC_WIDTH_CONDENSED	75
#define FC_WEIGHT_REGULAR	80
#define FC_WIDTH_SEMICONDENSED	87
#define FC_DUAL	90
#define FC_ANTIALIAS	"antialias"
#define FC_ASPECT	"aspect"
#define FC_AUTOHINT	"autohint"
#define FC_CAPABILITY	"capability"
#define FC_CHAR_HEIGHT	"charheight"
#define FC_CHARSET	"charset"
#define FC_CHAR_WIDTH	"charwidth"
#define FC_DPI	"dpi"
#define FC_EMBOLDEN	"embolden"
#define FC_FAMILY	"family"
#define FC_FAMILYLANG	"familylang"
#define FC_WEIGHT_HEAVY	FC_WEIGHT_BLACK
#define FC_WEIGHT_SEMIBOLD	FC_WEIGHT_DEMIBOLD
#define FC_WEIGHT_ULTRABOLD	FC_WEIGHT_EXTRABOLD
#define FC_WEIGHT_ULTRALIGHT	FC_WEIGHT_EXTRALIGHT
#define FC_WEIGHT_NORMAL	FC_WEIGHT_REGULAR
#define FC_FILE	"file"
#define FC_FONTFORMAT	"fontformat"
#define FC_FONTVERSION	"fontversion"
#define FC_FOUNDRY	"foundry"
#define FC_FT_FACE	"ftface"
#define FC_FULLNAME	"fullname"
#define FC_FULLNAMELANG	"fullnamelang"
#define FC_GLOBAL_ADVANCE	"globaladvance"
#define FC_HINTING	"hinting"
#define FC_HINT_STYLE	"hintstyle"
#define FC_INDEX	"index"
#define FC_LANG	"lang"
#define FC_MATRIX	"matrix"
#define FC_MINSPACE	"minspace"
#define FC_OUTLINE	"outline"
#define FC_PIXEL_SIZE	"pixelsize"
#define FC_RASTERIZER	"rasterizer"
#define FC_RGBA	"rgba"
#define FC_SCALABLE	"scalable"
#define FC_SCALE	"scale"
#define FC_SIZE	"size"
#define FC_SLANT	"slant"
#define FC_SOURCE	"source"
#define FC_SPACING	"spacing"
#define FC_STYLE	"style"
#define FC_STYLELANG	"stylelang"
#define FC_VERTICAL_LAYOUT	"verticallayout"
#define FC_WEIGHT	"weight"
#define FC_WIDTH	"width"


    typedef int FcBool;

    typedef struct _FcPattern FcPattern;

    typedef enum _FcType {
	FcTypeVoid = 0,
	FcTypeInteger = 1,
	FcTypeDouble = 2,
	FcTypeString = 3,
	FcTypeBool = 4,
	FcTypeMatrix = 5,
	FcTypeCharSet = 6,
	FcTypeFTFace = 7,
	FcTypeLangSet = 8
    } FcType;

    typedef unsigned char FcChar8;

    typedef struct _FcMatrix FcMatrix;

    typedef struct _FcCharSet FcCharSet;

    typedef struct _FcLangSet FcLangSet;

    typedef struct _FcValue FcValue;

    typedef struct _FcStrList FcStrList;

    typedef struct _FcConfig FcConfig;

    typedef struct _FcStrSet FcStrSet;

    typedef unsigned int FcChar32;

    typedef enum _FcMatchKind {
	FcMatchPattern = 0,
	FcMatchFont = 1
    } FcMatchKind;

    typedef struct _FcObjectSet FcObjectSet;

    typedef enum {
	FcEndianBig = 0,
	FcEndianLittle = 1
    } FcEndian;

    typedef struct _FcAtomic FcAtomic;

    typedef struct _FcConstant FcConstant;

    typedef struct _FcFontSet FcFontSet;

    typedef enum _FcSetName {
	FcSetSystem = 0,
	FcSetApplication = 1
    } FcSetName;

    typedef struct _FcBlanks FcBlanks;

    typedef enum _FcResult {
	FcResultMatch = 0,
	FcResultNoMatch = 1,
	FcResultTypeMismatch = 2,
	FcResultNoId = 3,
	FcResultOutOfMemory = 4
    } FcResult;

    typedef struct _FcObjectType FcObjectType;

    typedef struct _FcGlobalCache FcGlobalCache;

    typedef enum _FcLangResult {
	FcLangEqual = 0,
	FcLangDifferentCountry = 1,
	FcLangDifferentLang = 2
    } FcLangResult;

    typedef short unsigned int FcChar16;





    struct _FcMatrix {
	double xx;
	double xy;
	double yx;
	double yy;
    };








    struct _FcValue {
	FcType type;
	union {
	    const FcChar8 *s;
	    int i;
	    FcBool b;
	    double d;
	    const FcMatrix *m;
	    const FcCharSet *c;
	    void *f;
	    const FcPattern *p;
	    const FcLangSet *l;
	} u;
    };











    struct _FcObjectSet {
	int nobject;
	int sobject;
	const char **objects;
    };





    struct _FcConstant {
	const FcChar8 *name;
	const char *object;
	int value;
    };


    struct _FcFontSet {
	int nfont;
	int sfont;
	FcPattern **fonts;
    };





    struct _FcObjectType {
	const char *object;
	FcType type;
    };





    extern FcBool FcPatternAdd(FcPattern *, const char *, FcValue, FcBool);
    extern FcStrList *FcConfigGetConfigFiles(FcConfig *);
    extern FcBool FcStrSetAdd(FcStrSet *, const FcChar8 *);
    extern FcBool FcCharSetIsSubset(const FcCharSet *, const FcCharSet *);
    extern void FcDefaultSubstitute(FcPattern *);
    extern FcChar32 FcCharSetIntersectCount(const FcCharSet *,
					    const FcCharSet *);
    extern FcBool FcConfigUptoDate(FcConfig *);
    extern void FcPatternDestroy(FcPattern *);
    extern FcLangSet *FcLangSetCopy(const FcLangSet *);
    extern FcBool FcPatternAddCharSet(FcPattern *, const char *,
				      const FcCharSet *);
    extern FcBool FcPatternAddLangSet(FcPattern *, const char *,
				      const FcLangSet *);
    extern void FcConfigAppFontClear(FcConfig *);
    extern int FcConfigGetRescanInverval(FcConfig *);
    extern FcBool FcConfigSubstitute(FcConfig *, FcPattern *, FcMatchKind);
    extern FcObjectSet *FcObjectSetBuild(const char *, ...);
    extern FcBool FcObjectSetAdd(FcObjectSet *, const char *);
    extern FcChar32 FcCharSetSubtractCount(const FcCharSet *,
					   const FcCharSet *);
    extern FcBool FcUtf16Len(const FcChar8 *, FcEndian, int, int *, int *);
    extern FcBool FcConfigBuildFonts(FcConfig *);
    extern FcChar8 *FcAtomicOrigFile(FcAtomic *);
    extern FcBool FcNameUnregisterConstants(const FcConstant *, int);
    extern FcBool FcConfigSetRescanInverval(FcConfig *, int);
    extern FcBool FcAtomicLock(FcAtomic *);
    extern FcPattern *FcPatternBuild(FcPattern *, ...);
    extern FcFontSet *FcConfigGetFonts(FcConfig *, FcSetName);
    extern void FcStrListDone(FcStrList *);
    extern FcBool FcLangSetEqual(const FcLangSet *, const FcLangSet *);
    extern const FcConstant *FcNameGetConstant(FcChar8 *);
    extern void FcMatrixShear(FcMatrix *, double, double);
    extern FcMatrix *FcMatrixCopy(const FcMatrix *);
    extern FcStrList *FcConfigGetConfigDirs(FcConfig *);
    extern FcBool FcStrSetDel(FcStrSet *, const FcChar8 *);
    extern FcBool FcConfigEnableHome(FcBool);
    extern FcStrSet *FcStrSetCreate(void);
    extern int FcStrCmpIgnoreCase(const FcChar8 *, const FcChar8 *);
    extern FcCharSet *FcCharSetUnion(const FcCharSet *, const FcCharSet *);
    extern FcObjectSet *FcObjectSetCreate(void);
    extern FcBlanks *FcBlanksCreate(void);
    extern void FcBlanksDestroy(FcBlanks *);
    extern FcBool FcNameConstant(FcChar8 *, int *);
    extern void FcMatrixRotate(FcMatrix *, double, double);
    extern FcPattern *FcNameParse(const FcChar8 *);
    extern void FcMatrixMultiply(FcMatrix *, const FcMatrix *,
				 const FcMatrix *);
    extern FcResult FcPatternGetLangSet(const FcPattern *, const char *,
					int, FcLangSet * *);
    extern FcValue FcValueSave(FcValue);
    extern void FcAtomicDestroy(FcAtomic *);
    extern FcBool FcPatternEqual(const FcPattern *, const FcPattern *);
    extern FcBool FcNameRegisterObjectTypes(const FcObjectType *, int);
    extern FcChar32 FcCharSetNextPage(const FcCharSet *, FcChar32 *,
				      FcChar32 *);
    extern FcBool FcConfigSetCurrent(FcConfig *);
    extern FcPattern *FcFreeTypeQuery(const FcChar8 *, int, FcBlanks *,
				      int *);
    extern FcChar8 *FcStrListNext(FcStrList *);
    extern FcBool FcNameRegisterConstants(const FcConstant *, int);
    extern void FcValueDestroy(FcValue);
    extern FcBool FcFileScan(FcFontSet *, FcStrSet *, FcGlobalCache *,
			     FcBlanks *, const FcChar8 *, FcBool);
    extern FcFontSet *FcFontSetSort(FcConfig *, FcFontSet * *, int,
				    FcPattern *, FcBool, FcCharSet * *,
				    FcResult *);
    extern FcResult FcPatternGetString(const FcPattern *, const char *,
				       int, FcChar8 * *);
    extern FcChar8 *FcStrCopy(const FcChar8 *);
    extern FcBool FcPatternEqualSubset(const FcPattern *,
				       const FcPattern *,
				       const FcObjectSet *);
    extern FcConfig *FcInitLoadConfig(void);
    extern FcStrList *FcStrListCreate(FcStrSet *);
    extern FcResult FcPatternGetCharSet(const FcPattern *, const char *,
					int, FcCharSet * *);
    extern FcPattern *FcPatternCreate(void);
    extern FcChar32 FcPatternHash(const FcPattern *);
    extern FcChar8 *FcConfigFilename(const FcChar8 *);
    extern FcBool FcPatternDel(FcPattern *, const char *);
    extern FcCharSet *FcCharSetCopy(FcCharSet *);
    extern FcBool FcInitReinitialize(void);
    extern FcFontSet *FcFontList(FcConfig *, FcPattern *, FcObjectSet *);
    extern int FcUcs4ToUtf8(FcChar32, FcChar8 *);
    extern FcBool FcAtomicReplaceOrig(FcAtomic *);
    extern FcObjectSet *FcObjectSetVaBuild(const char *, va_list);
    extern FcBool FcInitBringUptoDate(void);
    extern FcResult FcPatternGetDouble(const FcPattern *, const char *,
				       int, double *);
    extern int FcStrCmp(const FcChar8 *, const FcChar8 *);
    extern FcChar8 *FcConfigGetCache(FcConfig *);
    extern FcAtomic *FcAtomicCreate(const FcChar8 *);
    extern FcPattern *FcPatternDuplicate(const FcPattern *);
    extern FcChar8 *FcStrDirname(const FcChar8 *);
    extern FcBool FcConfigSubstituteWithPat(FcConfig *, FcPattern *,
					    FcPattern *, FcMatchKind);
    extern FcBool FcDirScan(FcFontSet *, FcStrSet *, FcGlobalCache *,
			    FcBlanks *, const FcChar8 *, FcBool);
    extern FcChar8 *FcStrCopyFilename(const FcChar8 *);
    extern FcBool FcLangSetAdd(FcLangSet *, const FcChar8 *);
    extern FcResult FcPatternGetInteger(const FcPattern *, const char *,
					int, int *);
    extern FcBool FcConfigParseAndLoad(FcConfig *, const FcChar8 *,
				       FcBool);
    extern FcBool FcStrSetEqual(FcStrSet *, FcStrSet *);
    extern FcBool FcConfigAppFontAddFile(FcConfig *, const FcChar8 *);
    extern FcPattern *FcFontSetMatch(FcConfig *, FcFontSet * *, int,
				     FcPattern *, FcResult *);
    extern FcBool FcStrSetAddFilename(FcStrSet *, const FcChar8 *);
    extern FcChar8 *FcNameUnparse(FcPattern *);
    extern FcChar32 FcCharSetFirstPage(const FcCharSet *, FcChar32 *,
				       FcChar32 *);
    extern void FcFontSetPrint(const FcFontSet *);
    extern FcPattern *FcPatternVaBuild(FcPattern *, va_list);
    extern FcChar8 *FcConfigHome(void);
    extern FcBool FcBlanksAdd(FcBlanks *, FcChar32);
    extern FcBool FcBlanksIsMember(FcBlanks *, FcChar32);
    extern FcBool FcNameUnregisterObjectTypes(const FcObjectType *, int);
    extern FcLangResult FcLangSetHasLang(const FcLangSet *,
					 const FcChar8 *);
    extern FcChar8 *FcStrBasename(const FcChar8 *);
    extern FcPattern *FcFontMatch(FcConfig *, FcPattern *, FcResult *);
    extern void FcValuePrint(const FcValue);
    extern FcLangSet *FcLangSetCreate(void);
    extern FcStrList *FcConfigGetFontDirs(FcConfig *);
    extern FcBool FcCharSetAddChar(FcCharSet *, FcChar32);
    extern FcCharSet *FcCharSetIntersect(const FcCharSet *,
					 const FcCharSet *);
    extern void FcMatrixScale(FcMatrix *, double, double);
    extern void FcPatternReference(FcPattern *);
    extern FcBool FcCharSetEqual(const FcCharSet *, const FcCharSet *);
    extern FcBool FcFontSetAdd(FcFontSet *, FcPattern *);
    extern FcChar8 *FcAtomicNewFile(FcAtomic *);
    extern FcFontSet *FcFontSetList(FcConfig *, FcFontSet * *, int,
				    FcPattern *, FcObjectSet *);
    extern void FcFontSetSortDestroy(FcFontSet *);
    extern FcBool FcPatternAddMatrix(FcPattern *, const char *,
				     const FcMatrix *);
    extern FcChar32 FcCharSetCount(const FcCharSet *);
    extern FcBool FcPatternAddString(FcPattern *, const char *,
				     const FcChar8 *);
    extern void FcStrSetDestroy(FcStrSet *);
    extern FcConfig *FcConfigGetCurrent(void);
    extern FcBool FcPatternAddInteger(FcPattern *, const char *, int);
    extern FcResult FcPatternGetMatrix(const FcPattern *, const char *,
				       int, FcMatrix * *);
    extern int FcGetVersion(void);
    extern FcBool FcCharSetHasChar(const FcCharSet *, FcChar32);
    extern FcBool FcPatternAddBool(FcPattern *, const char *, FcBool);
    extern const FcObjectType *FcNameGetObjectType(const char *);
    extern FcBool FcDirCacheValid(const FcChar8 *);
    extern FcBool FcUtf8Len(const FcChar8 *, int, int *, int *);
    extern FcConfig *FcInitLoadConfigAndFonts(void);
    extern FcResult FcPatternGetBool(const FcPattern *, const char *, int,
				     FcBool *);
    extern void FcFontSetDestroy(FcFontSet *);
    extern FcBool FcConfigAppFontAddDir(FcConfig *, const FcChar8 *);
    extern int FcUtf16ToUcs4(const FcChar8 *, FcEndian, FcChar32 *, int);
    extern int FcUtf8ToUcs4(const FcChar8 *, FcChar32 *, int);
    extern FcFontSet *FcFontSetCreate(void);
    extern FcBool FcDirSave(FcFontSet *, FcStrSet *, const FcChar8 *);
    extern void FcConfigDestroy(FcConfig *);
    extern FcBool FcPatternAddDouble(FcPattern *, const char *, double);
    extern FcFontSet *FcFontSort(FcConfig *, FcPattern *, FcBool,
				 FcCharSet * *, FcResult *);
    extern FcPattern *FcFontRenderPrepare(FcConfig *, FcPattern *,
					  FcPattern *);
    extern void FcLangSetDestroy(FcLangSet *);
    extern void FcCharSetDestroy(FcCharSet *);
    extern FcBool FcValueEqual(FcValue, FcValue);
    extern FcBool FcPatternAddWeak(FcPattern *, const char *, FcValue,
				   FcBool);
    extern FcBool FcLangSetContains(const FcLangSet *, const FcLangSet *);
    extern void FcObjectSetDestroy(FcObjectSet *);
    extern FcCharSet *FcCharSetCreate(void);
    extern FcLangResult FcLangSetCompare(const FcLangSet *,
					 const FcLangSet *);
    extern FcBool FcMatrixEqual(const FcMatrix *, const FcMatrix *);
    extern void FcAtomicUnlock(FcAtomic *);
    extern FcBool FcStrSetMember(FcStrSet *, const FcChar8 *);
    extern FcChar32 FcLangSetHash(const FcLangSet *);
    extern void FcAtomicDeleteNew(FcAtomic *);
    extern FcCharSet *FcCharSetSubtract(const FcCharSet *,
					const FcCharSet *);
    extern FcBool FcInit(void);
    extern FcResult FcPatternGet(const FcPattern *, const char *, int,
				 FcValue *);
    extern void FcPatternPrint(const FcPattern *);
    extern FcBlanks *FcConfigGetBlanks(FcConfig *);
#ifdef __cplusplus
}
#endif
#endif
