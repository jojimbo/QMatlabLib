@echo off

if (%~1) == () goto usage

echo Market Data Folder is  set to (%~1).
echo Running...
set classpath=".\mdsimport\lib\woodstox-core-asl-4.1.2.jar;.\mdsimport\lib\stax2-api-3.1.1.jar;.\mdsimport\lib\msv-core-2010.2.jar;.\mdsimport\lib\woodstox-msv-rng-datatype-20020414.jar;.\mdsimport\lib\xsdlib-2010.1.jar;.\mdsimport\lib\ojdbc6.jar;.\mdsimport\lib\mds.jar;.\mdsimport\lib\mdsimport.jar"
 

java  -Dmds.ImportType=DataSeries -Dmds.MarketDataPath=%~1  -Djava.util.logging.config.file=.\logging.properties -Dmds.properties.file=.\mdsimport.properties -classpath %classpath% mdsimport.MDSImport


echo Done.
goto end

:usage
echo Market Data Folder is not set.
echo "Usage: %~0 XMLDir"

:end


