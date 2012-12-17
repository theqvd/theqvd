# Get these in order
#SUBDIRS=src jni/c jni/java jni/jqvdclient
SUBDIRS=libqvdclientwrapper jni  jqvdclient  
TARGETARCH=

Default: all

all clean distclean test: $(SUBDIRS)
	$(eval TARGET:=$@)
	for i in $(SUBDIRS); do\
	    $(MAKE) -C $$i $(TARGET) || exit 1;\
	done

.PHONY: all clean distclean
