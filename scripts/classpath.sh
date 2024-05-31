#!/bin/sh

echo "Run this with \"source $0\" to set the CLASSPATH environment variable!"

export JAVAOPTS="-Ddebug=true -Dorg.slf4j.simpleLogger.defaultLogLevel=info"

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

export CLASSPATH=$CP
