#!/bin/sh

if [ -d "./Deploy" ] ; then
	echo "The deployment directory already exists. Deleting the directory..."
	rm -rf "./Deploy"
fi

mkdir "./Deploy"
mkdir "./Deploy/Cache"
mkdir "./Deploy/RSGSource"

mkdir "./Deploy/ARAReports"
mkdir "./Deploy/marketData"

echo "The deployment directory(./Deploy) is created."

echo "Copying the deployment packages..."

cp -r RSGSimulate ./Deploy
cp -r RSGSimulateRunner ./Deploy
cp -r Lib ./Deploy
cp -r "+prursg" ./Deploy/RSGSource
cp -r "Schemas" ./Deploy/RSGSource
cp -r "+Model" ./Deploy/RSGSource
cp -r "+Bootstrap" ./Deploy/RSGSource
cp -r "+BootstrapValidation" ./Deploy/RSGSource
cp -r "+Converter" ./Deploy/RSGSource
cp app.config ./Deploy

cp classpath.txt ./Deploy
cp fix_classpath.sh ./Deploy
cd ./Deploy/
./fix_classpath.sh
cd ..

cp ParallelConfig.mat ./Deploy
cp run_runner.sh ./Deploy
cp java.opts ./Deploy

echo "Copying data folders..."
mkdir ./Deploy/+prursg
cd ./Deploy/+prursg
mkdir +Algo
mkdir +BootstrapValidation
mkdir java
cd java
mkdir db
mkdir xml
cd ..
cd ..
cd ..

cp -r "+prursg/+Algo/+Data" "./Deploy/+prursg/+Algo"
cp -r "+prursg/+Algo/XmlTemplates" "./Deploy/+prursg/+Algo"
cp -r "+prursg/+BootstrapValidation/+XmlTemplates" "./Deploy/+prursg/+BootstrapValidation"
cp  +prursg/java/db/*.class "./Deploy/+prursg/java/db"
cp  +prursg/java/xml/*.class "./Deploy/+prursg/java/xml"

echo "Deployment completed."




