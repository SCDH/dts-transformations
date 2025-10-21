#!/bin/sh

SCRIPT=$(realpath "$0")
PROJECTPATH=$(dirname "$SCRIPT")/..

$PROJECTPATH/target/bin/xslt.sh -config:$PROJECTPATH/test/saxon.xml -xsl:$PROJECTPATH/xsl/navigation.xsl -it -ea:on $@
