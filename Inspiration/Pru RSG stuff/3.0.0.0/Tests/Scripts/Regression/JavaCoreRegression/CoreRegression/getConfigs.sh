#!/usr/bin/env bash

# Until we have a better scheme copy the core regression templates over
configDir=./configs
mkdir $configDir

cp ../../CoreRegression/*.config.template $configDir
cp ../../CoreRegression/xunit.test.folder $configDir
cp ../../CoreRegression/configure.sh .

chmod a+x configure.sh

