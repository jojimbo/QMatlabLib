#!/usr/bin/env sh

flags="-nosplash"
matlab_workaround=
	
# Add arg processing to allow more flexibility
# Requires either cl or ide appear as the first argument to the script.

case "$1" in
	[iI][dD][eE])
        	echo "Executing tests in the IDE"
		shift
		break;;
	*)
        	echo "Executing tests on the command line"
		flags="$flags -nodesktop"
		manual_matlab_workaround="required"
		break;;
esac

flags="$flags -logfile ./$(date +'%F-%T').logfile"

matlab "$flags" -r "runtests $@;" 

# We need to call GetModelsPackage add the Models folder to the path explicitly 
# as it's only called by the RSG during simulation and boostrapping etc. 
# If a test requires models but is not performing one of these operations it will
# fail to find the model. See CASD830344 configuration test for an example  

if [ -z "$manual_matlab_workaround" ]; then
	# if running in the ide it's safe to invoke reset
	reset
else
	echo "Due to a defect in Matlab you may now need to type 'reset' for the shell to echo user input"
	# workaround for bug in Matlab R2010a.
	# After running Matlab with the -nodesktopm or -nojvm flags the terminal
	# no longer echos keyboard input
fi
