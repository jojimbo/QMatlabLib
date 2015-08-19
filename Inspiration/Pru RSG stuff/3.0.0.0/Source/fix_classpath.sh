#!/bin/env bash

classpath=classpath.txt
suffix=.bak.$$$$

#sed -i$suffix -e'/.*poi[0-9.-]*jar.*/d' -e'/.*mds[0-9.-]*jar.*/d' -e'/.*ojdbc[0-9.]*jar.*/d' -e'/^\W*$/d' $classpath

libs=$(cat<<-HERE	
	./Lib/poi-3.7/poi-3.7-20101029.jar
	./Lib/poi-3.7/poi-ooxml-3.7-20101029.jar
	./Lib/poi-3.7/poi-ooxml-schemas-3.7-20101029.jar
	./Lib/poi-3.7/ooxml-lib/xmlbeans-2.3.0.jar
	./Lib/poi-3.7/ooxml-lib/geronimo-stax-api_1.0_spec-1.0.jar
	./Lib/poi-3.7/ooxml-lib/dom4j-1.6.1.jar

	./Lib/ojdbc6.jar
	./Lib/mds.jar
HERE)

# Uncomment this line if you want to add all libs in Source/Lib
# libs=$(find ./Lib -type f -iname \*.jar)

# Back up original in case sed is too hungry
cp $classpath $classpath.$suffix

for lib in $libs; do
	target=$(readlink -e $lib)
	filename=$(basename $target)
	echo "Removing '$filename' from '$classpath'"
	
	# Edit in place
	sed -i -e"/^.*${filename}$/d" -e'/^\W*$/d' $classpath
	echo "Adding '$target' to '$classpath'"
	echo "$target" >> $classpath
done
