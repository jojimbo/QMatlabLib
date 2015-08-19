#!/bin/sh
# Builds a java runner for java distributable

JDK=/apps/jdk1.6.0_20/bin/
JAVABUILDER=/apps/MATLAB/R2010b/toolbox/javabuilder

if [ "x$1" = "x" ] ; then
	echo "usage: $0 (project name without extension)"
fi

DIST=$1
# Only needed for mcc build where archives have first lowercase letter
# AWK=/usr/bin/awk
# Make first character of project name lower case!
# LDIST=`echo $1 | $AWK 'BEGIN{OFS=FS="|"} {print tolower(substr($1,1,1))substr($1,2)}'`
LDIST=$DIST

RUNNER="$1Runner"
if [ ! -d "./$DIST" ] ; then
	echo "Java distributable project $DIST does not exist"
	exit 1
fi

if [ ! -d "./$RUNNER" ] ; then
	echo "Runner source directory ./$RUNNER does not exist"
	exit 1
fi

if [ ! -f "./$RUNNER/$RUNNER.java" ] ; then
	echo "Runner source file ./$RUNNER/$RUNNER.java does not exist, so there!"
	exit 1
fi

(cd ./$RUNNER; PATH=$JDK:$PATH javac $2 -classpath ../$DIST/src/${LDIST}.jar:$JAVABUILDER/jar/javabuilder.jar $RUNNER.java)

