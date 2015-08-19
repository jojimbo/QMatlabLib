#!/usr/bin/env bash

MCR_HOME=/apps/MCR/R2010bSP1
# MATLAB_HOME=/apps/MATLAB/R2010bSP1

export LD_LIBRARY_PATH=\
${MCR_HOME}/v7141/runtime/glnxa64:\
${MCR_HOME}/v7141/sys/os/glnxa64:\
${MCR_HOME}/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:\
${MCR_HOME}/v7141/sys/java/jre/glnxa64/jre/lib/amd64/native_server:\
${MCR_HOME}/v7141/sys/java/jre/glnxa64/jre/lib/amd64:\
$LD_LIBRARY_PATH

#${MATLAB_HOME}/runtime/glnxa64:\
#${MATLAB_HOME}/sys/os/glnxa64:\
#${MATLAB_HOME}/bin/glnxa64:\
#${MATLAB_HOME}/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:\
#${MATLAB_HOME}/sys/java/jre/glnxa64/jre/lib/amd64/server:\
#${MATLAB_HOME}/sys/java/jre/glnxa64/jre/lib/amd64:\
#$LD_LIBRARY_PATH

export MCR_CACHE_VERBOSE=1
export MCR_CACHE_ROOT=/tmp

# echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

#eclipse -nosplash -data $PWD -vmargs -Xmx1G -Djave.library.path=$LD_LIBRARY_PATH &
eclipse -nosplash -data .. -vmargs -Xmx14336m &
# eclipse -nosplash -data $PWD -vmargs -Xmx512M &
