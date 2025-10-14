#!/bin/sh

JAVAOPTS="-Ddebug=${DEBUG:-false} -Dorg.slf4j.simpleLogger.defaultLogLevel=info"

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

java $JAVAOPTS -cp $CP net.sf.saxon.Transform $@
