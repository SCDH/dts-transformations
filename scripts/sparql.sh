#!/bin/sh

JAVAOPTS=-Ddebug="true" 

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

java $JAVAOPTS -cp $CP arq.sparql $@
