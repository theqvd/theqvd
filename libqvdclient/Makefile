# Get these in order
#SUBDIRS=src jni/c jni/java jni/jqvdclient
SUBDIRS=c
TARGETARCH=
TESTHOST=qvddemo.theqvd.com
TESTUSER=test@qindel.com
TESTPASS=test
ARGS4J=$$HOME/.m2/repository/args4j/args4j/2.0.16/args4j-2.0.16.jar

default: all

all clean distclean: $(SUBDIRS)
	$(eval TARGET:=$@)
	for i in $(SUBDIRS); do\
	    $(MAKE) -C $$i $(TARGET);\
	done

.PHONY: all clean distclean
