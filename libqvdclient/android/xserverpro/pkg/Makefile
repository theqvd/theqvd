VERSION=1.0
APKUNSIGNED=xvncpro-unsigned.apk
APKSIGNED=xvncpro-signed.apk
APKALIGNED=xvncpro.apk
KEYSTORE=$(HOME)/w/nito/keys/my-android-release-key.keystore

all: $(APKALIGNED)

$(APKALIGNED): $(APKSIGNED)
	rm -f $(APKALIGNED)
	zipalign -v 4 $(APKSIGNED) $(APKALIGNED)
	ln $(APKALIGNED) $(APKALIGNED)-`date +%Y%m%d%H%M%S`

$(APKSIGNED): $(APKUNSIGNED)
	cp $(APKUNSIGNED) $(APKSIGNED)
	jarsigner -verbose -keystore $(KEYSTORE) $(APKSIGNED) nitomartinez || rm -f $(APKSIGNED)

verify:
	jarsigner -verify $(APKSIGNED)

verifyverbose:
	jarsigner -verify -verbose -certs $(APKSIGNED)

clean:
	rm -f *~ $(APKSIGNED)

distclean: clean
	rm $(APKUNSIGNED) $(APKALIGNED)
