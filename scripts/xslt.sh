#!/bin/sh

JAVAOPTS="-Ddebug=true -Dorg.slf4j.simpleLogger.defaultLogLevel=info"

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

java -cp $CP net.sf.saxon.Transform $@
