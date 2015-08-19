@echo off

:: enable extensions for case insensitive string comparison
setlocal enableextensions

set flags=-nosplash	

IF /I "%1" EQU "IDE" (
	echo Executing scripts in the IDE
) ELSE (
	echo Executing scripts on the command line
	set flags=%flags% -nodesktop
)

set root=%CD%

IF %# EQU 1 (
	set target="%1"
) ELSE (
	set target=%root%
)

matlab %flags% -r "addpath('%root%/framework'); testsetup('%root%', '%target%');"

