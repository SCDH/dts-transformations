#!/bin/sh

JAVAOPTS="-Ddebug=true -Dorg.slf4j.simpleLogger.defaultLogLevel=info -Dxspec.version=${xspec.version}"

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

java $JAVAOPTS -cp $CP org.apache.tools.ant.Main $@
