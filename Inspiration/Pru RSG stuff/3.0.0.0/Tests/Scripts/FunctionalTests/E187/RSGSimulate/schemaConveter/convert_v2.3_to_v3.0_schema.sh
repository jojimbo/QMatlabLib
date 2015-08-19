#!/usr/bin/env bash

target=$1
if [ ! -e "$target" ]; then
	echo "Expecting one argument, a v2.3.0.0 schema XML control file"
	echo "'$target' not found!"
	exit 1
fi

riskProperties='<risk_properties><property name="corr_group" type="string">FIXME</property><property name="suppress_output" type="string">false</property></risk_properties>' 
schemaVersion='<PruRSG xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="RSGSchema_3.0.0.0.xsd">'

sed \
-e"s|<PruRSG>|$schemaVersion|" \
-e"s|\(<correlation_matrix\)>|\1 source='ControlFile'>|" \
-e"s|\(<rng_properties>\)|$riskProperties\1|g" \
"$target"


