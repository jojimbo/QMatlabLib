@echo off

:: enable extensions for case insensitive string comparison
setlocal enableextensions

set flags=-nosplash	

IF /I "%1" EQU "IDE" (
	echo Executing tests in the IDE
	shift
) ELSE (
	echo Executing tests on the command line
	set flags=%flags% -nodesktop
)

set flags=%flags% -logfile "%DATE:/=%-%TIME::=%.logfile"

matlab %flags% -r "runtests %1 %2 %3 %4 %5 %6 %7 %8 %9"; 
