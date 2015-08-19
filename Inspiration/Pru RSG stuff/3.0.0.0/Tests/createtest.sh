#!/usr/bin/env sh

if [ $# -ne 3 ]; then
cat <<END
Name:
	$0 - Create boiler plate test files

Synopsis: 
	$0 'test_folder' 'test_name' 'description'

Description:
	Create a folder structure of the form test_folder/test_name containing
	test template and framework files

Example:
	$0 Scripts/FunctionalTest QC123 'Test new functionality for QC23'

	$0 Scripts/Installation base_simulation 'Test the installation'
	
	$0 Scripts/FunctionalTest/CR1234 SomeFunction 'A Test'
	$0 Scripts/FunctionalTest/CR1234 SomeOtherFunction 'Another Test'
END
	exit 1
fi

root=$PWD
matlab -nosplash -nodesktop -r "addpath('$root/framework'); createtest('$root', '$1', '$2', '$3'); quit"
