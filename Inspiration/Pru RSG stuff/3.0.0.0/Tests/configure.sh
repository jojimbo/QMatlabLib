#!/usr/bin/env sh

flags="-nosplash"
matlab_workaround=
	
# Add arg processing to allow more flexibility
# Requires either cl or ide appear as the first argument to the script.

case "$1" in
   	[cC][lL])
		echo "Executing scripts on the command line"
		flags="$flags -nodesktop"
		manual_matlab_workaround="required"
		shift
		break;;
	[iI][dD][eE])
		echo "Executing scripts in the IDE"
		shift
		break;;
	*)
		echo "Executing scripts on the command line"
		flags="$flags -nodesktop"
		manual_matlab_workaround="required"
		break;;
esac

root=$PWD

if [ $# -eq 1 ]; then
	target="$1"
else
	target="$root"
fi

matlab "$flags" -r "\
addpath('$root/framework');\
testsetup('$root', '$target');
"

if [ -z "$manual_matlab_workaround" ]; then
	# if running in the ide it's safe to invoke reset
	reset
else
	echo "Due to a defect in Matlab you may now need to type 'reset' for the shell to echo user input"
	# workaround for bug in Matlab R2010a.
	# After running Matlab with the -nodesktopm or -nojvm flags the terminal
	# no longer echos keyboard input
fi
