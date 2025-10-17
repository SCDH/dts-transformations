URLS_FILE ?= test/community-cases.txt
BASE_URL ?= https://raw.githubusercontent.com/distributed-text-services/MyDapytains/refs/heads/main/tests/tei
URLS := $(shell cat $(URLS_FILE))
NAVIGATION := $(patsubst $(BASE_URL)/%.xml,dist/navigation/%.json,$(URLS)) 

WSCRD ?= target/bin
SAXON ?= $(WSCRD)/xslt.sh

# .PHONY	: all CP dist/navigation

all:	CP $(NAVIGATION)

CP:	$(WSCRD)/classpath.sh
	$(shell source $<)

dist/navigation:
	mkdir -p $@

dist/navigation/%.json: dist/navigation
	$(SAXON) -config:test/saxon.xml \
	-xsl:xsl/navigation.xsl \
	-s:$(BASE_URL)/$(notdir $(patsubst %.json,%.xml,$@)) \
	-o:$@ \
	-ea:on 2> $@.log || echo "error on $@"

test.tgz:	$(NAVIGATION)
	tar -czf $@ dist/
