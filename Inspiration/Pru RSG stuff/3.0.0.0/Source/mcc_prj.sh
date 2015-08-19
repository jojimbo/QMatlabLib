#!/bin/sh
# Build a java redistributable using mcc and a predefined deployment project

if [ "x" = "$1x" ] ; then
	echo "usage: $0 [project file]"
	exit 1
fi
PRJ_FIL=$1
if [ ! -f "$PRJ_FIL" ] ; then
	PRJ_FILO=$PRJ_FIL
	PRJ_FIL="${PRJ_FIL}.prj"
fi
if [ ! -f "$PRJ_FIL" ] ; then
	echo "${PRJ_FILO}(.prj) isn't a project file"
	exit 1
fi

JDK=/usr/local/jdk1.5.0_07/bin
AWK=/usr/bin/awk
# Extract project base name (remove extension .prj)
PRJ_NAME=`echo $PRJ_FIL | ${AWK} 'BEGIN {FS = "[/\.]"}; { print $(NF-1)}'`
if [ ! -d "./${PRJ_NAME}/src" ] ; then
	mkdir -p "./${PRJ_NAME}/src"
fi

PATH=$JDK:$HOME/app/bin/:$PATH mcc -F $PRJ_FIL 
