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
J   += $(shell find src -type f -regex '.+.java$$')
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


updev: update $(OS)_updev maven_update
