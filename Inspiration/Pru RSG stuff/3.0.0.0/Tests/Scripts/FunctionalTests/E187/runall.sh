#!/bin/env bash

lsd=$(find . -maxdepth 1 -type d -not -path '.' -print) 

# Note it is assumed that all directories have been configured
# cd to iRSG/Tests/ and invoke ./configure.sh at that level if not - 
#
# e.g. iRSG/Tests$: ./configure.sh Scripts/FunctionalTests/E187
# or to configure all tests in one go iRSG/Tests$: ./configure.sh 
for dir in $lsd; do
	echo "Decending into '$dir'..."
	cwd=`pwd` 
	cd "$dir" && ./runtests.sh 2>&1 | tee ${cwd}/runall.log && cd ..
done
