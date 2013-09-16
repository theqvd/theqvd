# Get these in order
#SUBDIRS=src jni/c jni/java jni/jqvdclient
SUBDIRS=c java webplugin
TARGETARCH=

Default: all

all clean distclean: $(SUBDIRS)
	$(eval TARGET:=$@)
	for i in $(SUBDIRS); do\
	    $(MAKE) -C $$i $(TARGET) || exit 1;\
	done

test: checkenv-QVDTESTHOST checkenv-QVDTESTUSER checkenv-QVDTESTPASS checkenv-ARGS4J $(SUBDIRS)
	$(eval TARGET:=$@)
	for i in $(SUBDIRS); do\
	    $(MAKE) -C $$i $(TARGET) || exit 1;\
	done
	LD_LIBRARY_PATH=./c java -cp java/jqvdclient/target/classes:java/jni/target/classes:$(ARGS4J) -Djava.library.path=java/libqvdclientwrapper com.theqvd.client.jqvdclient.Jqvdclient -o -n -h $(QVDTESTHOST) -u $(QVDTESTUSER) -w $(QVDTESTPASS)

checkenv-%:
	@if [ -z "${${*}}" ]; then \
	  echo ${*} not defined, please set export ${*}=...; \
	  if [ "${*}" = "ARGS4J" ]; then echo "ARGS4J is usually in $(HOME)/.m2/repository/args4j/args4j/2.0.16/args4j-2.0.16.jar"; fi; \
          exit 1;\
	fi

.PHONY: all clean distclean
