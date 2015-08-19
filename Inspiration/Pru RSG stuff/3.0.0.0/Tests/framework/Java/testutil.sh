#!/usr/bin/env bash

# The app that calls the Java interface
DISTNAME=JTestUtility
PROJECTNAME=JTestUtil

OUTDIR=./$PROJECTNAME/generated
# The Java interface - The Matlab distributable
DIST=$OUTDIR/JavaBuilder/src/$DISTNAME.jar


if [ ! -e "$DIST" ] ; then
	echo "Java distributable $DIST does not exist"
	exit 1
fi

UTIL=$OUTDIR/$PROJECTNAME.class
if [ ! -f "$UTIL" ] ; then
	echo "Utility class file $UTIL does not exist. Try running the build script."
	exit 1
fi

JDK=/apps/jdk1.6.0_20/bin/
JAVABUILDER=/apps/MATLAB/R2010bSP1/toolbox/javabuilder/jar/javabuilder.jar
JAVA="$JAVA_HOME/bin/java -Xmx14336m" 
PATH=$JDK:$PATH

MCR_HOME=/apps/MCR/R2010bSP1
MCR=$MCR_HOME/v7141/runtime/glnxa64:$MCR_HOME/v714/sys/os/glnxa64
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_threads
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_server
MCR=$MCR:$MCR_HOME/v7141/sys/java/jre/glnxa64/jre/lib/amd64

LD_LIBRARY_PATH=$MCR:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

# Replaced absolute path to the jdbc drivers with a relative path ito the Lib directory 
# Assumes the script is executed in either the Source or the Source/Deploy folder of the RSG.
ORACLE_JDBC=$PROJECTNAME/Lib/ojdbc6.jar
echo "Using jdbc driver from $ORACLE_JDBC"

$JAVA -classpath $OUTDIR:$DIST:$JAVABUILDER:$ORACLE_JDBC $PROJECTNAME "$@"

