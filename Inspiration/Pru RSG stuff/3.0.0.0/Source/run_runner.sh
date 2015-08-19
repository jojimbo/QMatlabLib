#!/bin/sh
# Runs the redistributable test runner

JDK=/apps/jdk1.6.0_20/bin/
#MATLABROOT=$HOME/app/R2010b
JAVABUILDER=/apps/MATLAB/R2010bSP1/toolbox/javabuilder
#MCR=$MATLABROOT/runtime/glnxa64

if [ "x$1" = "x" ] ; then
	echo "usage: $0 (project name without extension)"
	exit 1
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

if [ ! -f "./$RUNNER/$RUNNER.class" ] ; then
	echo "Runner source file ./$RUNNER/$RUNNER.java does not exist, so there!"
	exit 1
fi

#PATH=$JDK:$PATH LD_LIBRARY_PATH=$MCR:$LD_LIBRARY_PATH java -Xmx14336m -classpath ./$RUNNER:./$DIST/src/${LDIST}.jar:$JAVABUILDER/jar/javabuilder.jar $RUNNER "$2" "$3" "$4" $5 $6 $7 $8 $9
PATH=$JDK:$PATH
MCR_HOME=/apps/MCR/R2010bSP1
MCR=$MCR_HOME/v7141/runtime/glnxa64:$MCR_HOME/v714/sys/os/glnxa64
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_threads
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_server
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64
LD_LIBRARY_PATH=$MCR:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

# Replaced absolute path to the jdbc drivers with a relative path by pointing to the Lib directory either within the Source or the Source/Deploy folder of the RSG.
ORACLE_JDBC=./Lib/ojdbc6.jar
echo $ORACLE_JDBC

# Added an argument to use 14GB of memory when calling java
$JAVA_HOME/bin/java -Xmx14336m -classpath ./$RUNNER:./$DIST/src/${LDIST}.jar:$JAVABUILDER/jar/javabuilder.jar:$ORACLE_JDBC $RUNNER "$2" "$3" $4 $5 $6 $7 $8 $9
