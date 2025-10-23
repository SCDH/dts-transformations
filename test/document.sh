#!/bin/sh

SCRIPT=$(realpath "$0")
PROJECTPATH=$(dirname "$SCRIPT")/..

$PROJECTPATH/target/bin/xslt.sh -config:$PROJECTPATH/test/saxon-no-local.xml -xsl:$PROJECTPATH/xsl/document.xsl -it -ea:on $@
