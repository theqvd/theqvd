#/**********************************************************\ 
#
# Auto-Generated Plugin Configuration file
# for QVD Web Client Plugin
#
#\**********************************************************/

set(PLUGIN_NAME "npqvd")
set(PLUGIN_PREFIX "npqvd")
set(COMPANY_NAME "theqvd")

# ActiveX constants:
set(FBTYPELIB_NAME npqvdLib)
set(FBTYPELIB_DESC "npqvd 1.0 Type Library")
set(IFBControl_DESC "npqvd Control Interface")
set(FBControl_DESC "npqvd Control Class")
set(IFBComJavascriptObject_DESC "npqvd IComJavascriptObject Interface")
set(FBComJavascriptObject_DESC "npqvd ComJavascriptObject Class")
set(IFBComEventSource_DESC "npqvd IFBComEventSource Interface")
set(AXVERSION_NUM "1")

# NOTE: THESE GUIDS *MUST* BE UNIQUE TO YOUR PLUGIN/ACTIVEX CONTROL!  YES, ALL OF THEM!
set(FBTYPELIB_GUID 63921bad-d026-5279-84ce-431ea592340f)
set(IFBControl_GUID d2342aed-faab-568f-9ffc-a19ae0277dcc)
set(FBControl_GUID c02b128b-e6d9-5745-ac38-03c5d4c7f28d)
set(IFBComJavascriptObject_GUID 3ba7a504-fac3-5573-b868-f54b0afc8596)
set(FBComJavascriptObject_GUID e3223a5d-7d13-54ea-a717-5424312256c4)
set(IFBComEventSource_GUID 3ca624de-b133-535a-ae0b-830c72d43678)
if ( FB_PLATFORM_ARCH_32 )
    set(FBControl_WixUpgradeCode_GUID 3ca74976-b05c-5014-b681-4d7e8bd02961)
else ( FB_PLATFORM_ARCH_32 )
    set(FBControl_WixUpgradeCode_GUID dd85a24f-2fd8-59f1-9f7e-a77d0a9719a8)
endif ( FB_PLATFORM_ARCH_32 )

# these are the pieces that are relevant to using it from Javascript
set(ACTIVEX_PROGID "theqvd.npqvd")
if ( FB_PLATFORM_ARCH_32 )
    set(MOZILLA_PLUGINID "theqvd.com/npqvd")  # No 32bit postfix to maintain backward compatability.
else ( FB_PLATFORM_ARCH_32 )
    set(MOZILLA_PLUGINID "theqvd.com/npqvd_${FB_PLATFORM_ARCH_NAME}")
endif ( FB_PLATFORM_ARCH_32 )

# strings
set(FBSTRING_CompanyName "QVD Dev Team")
set(FBSTRING_PluginDescription "Web client plugin for QVD. For further info see http://theqvd.com")
set(FBSTRING_PLUGIN_VERSION "1.0.0.0")
set(FBSTRING_LegalCopyright "Copyright 2013 QVD Dev Team")
set(FBSTRING_PluginFileName "np${PLUGIN_NAME}")
set(FBSTRING_ProductName "QVD Web Client Plugin")
set(FBSTRING_FileExtents "")
if ( FB_PLATFORM_ARCH_32 )
    set(FBSTRING_PluginName "QVD Web Client Plugin")  # No 32bit postfix to maintain backward compatability.
else ( FB_PLATFORM_ARCH_32 )
    set(FBSTRING_PluginName "QVD Web Client Plugin_${FB_PLATFORM_ARCH_NAME}")
endif ( FB_PLATFORM_ARCH_32 )
set(FBSTRING_MIMEType "application/theqvd")

# Uncomment this next line if you're not planning on your plugin doing
# any drawing:

set (FB_GUI_DISABLED 1)

# Mac plugin settings. If your plugin does not draw, set these all to 0
set(FBMAC_USE_QUICKDRAW 0)
set(FBMAC_USE_CARBON 0)
set(FBMAC_USE_COCOA 0)
set(FBMAC_USE_COREGRAPHICS 0)
set(FBMAC_USE_COREANIMATION 0)
set(FBMAC_USE_INVALIDATINGCOREANIMATION 0)

# If you want to register per-machine on Windows, uncomment this line
#set (FB_ATLREG_MACHINEWIDE 1)
