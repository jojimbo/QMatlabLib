#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 XMLDir" 
    exit 1
fi

XMLDir=$1
root=.

properties="-Dmds.ImportType=DataSeries -Dmds.MarketDataPath=$XMLDir -Djava.util.logging.config.file=$root/logging.properties -Dmds.properties.file=$root/mdsimport.properties"
classpath="$root:$root/mdsimport/bin:$root/mdsimport/lib/woodstox-core-asl-4.1.2.jar:$root/mdsimport/lib/stax2-api-3.1.1.jar:$root/mdsimport/lib/msv-core-2010.2.jar:$root/mdsimport/lib/woodstox-msv-rng-datatype-20020414.jar:$root/mdsimport/lib/xsdlib-2010.1.jar:$root/mdsimport/lib/ojdbc6.jar:$root/mdsimport/lib/mds.jar:$root/mdsimport/lib/mdsimport.jar"
 
/apps/jdk1.6.0_20/bin/java  $properties -classpath $classpath mdsimport.MDSImport

