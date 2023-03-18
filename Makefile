# var
MODULE = $(notdir $(CURDIR))
module = $(shell echo $(MODULE) | tr A-Z a-z)
OS     = $(shell uname -o|tr / _)
NOW    = $(shell date +%d%m%y)
REL    = $(shell git rev-parse --short=4 HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

# dirs
CWD = $(CURDIR)
BIN = $(CWD)/bin
DOC = $(CWD)/doc
SRC = $(CWD)/src
TMP = $(CWD)/tmp

# tool
CURL   = curl -L -o
CF     = clang-format
JAVA   = java  -cp $(BIN)
JAVAC  = javac  -d $(BIN)
MAVEN  = mvn

# src
J   += $(shell find src/main/java -type f -regex '.+.java$$')
POM  = pom.xml
S   += $(J) $(POM)

# cfg
TC   = target/classes
CP  += $(TC)
JAR  = target/$(MODULE)-$(BRANCH)-$(REL).jar

# all
.PHONY: all
all: classes
	$(JAVA) -cp $(CP) ponyatov.$(MODULE).App $(J)

.PHONY: classes
CLASSES  = $(shell echo $(J) | sed 's/src\/main\/java\//target\/classes\//g' | sed 's/.java/.class/g')
classes: $(CLASSES)
$(TC)/%.class: src/main/java/%.java
	javac -d $(TC) $^

.PHONY: jar
jar: $(JAR)
$(JAR): maven $(S)
	$(MAVEN) jar:jar -f $(POM) && touch $@

.PHONY: maven
maven: tmp/maven
tmp/maven: $(S) .git/refs/heads/$(BRANCH)
	$(MAVEN) versions:set -DgenerateBackupPoms=false -DnewVersion=$(BRANCH)-$(REL)
	touch $@

maven_update:
	$(MAVEN) versions:use-latest-versions

# format
.PHONY: format
format: tmp/format_java
tmp/format_java: $(J)
	$(CF) -style=file -i $? && touch $@

# doc
.PHONY: doc
doc:

# install
.PHONY: install update updev
install: $(OS)_install doc gz
	$(MAKE) update
update:  $(OS)_update
updev:   update $(OS)_updev maven_update

.PHONY: GNU_Linux_install GNU_Linux_update GNU_Linux_updev
GNU_Linux_install:
GNU_Linux_update:
ifneq (,$(shell which apt))
	sudo apt update
	sudo apt install -u `cat apt.txt`
endif
# Debian 10
ifeq ($(shell lsb_release -cs),buster)
#	sudo apt install -t buster-backports kicad
endif
GNU_Linux_updev:
	sudo apt install -yu `cat apt.dev`

.PHONY: gz
gz:

# merge
MERGE += README.md Makefile .gitignore apt.txt apt.dev LICENSE $(S)
MERGE += .vscode bin doc inc tmp src

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	$(MAKE) shadow

.PHONY: zip
zip:
	git archive \
		--format zip \
		--output $(TMP)/$(MODULE)_$(NOW)_$(REL).src.zip \
	HEAD
