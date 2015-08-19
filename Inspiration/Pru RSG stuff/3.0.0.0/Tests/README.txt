The first step is to set up environment variables:

iRSG/Tests$:. setup_test.env.sh

(note the '.' followed by a space and the script name.)
This loads variables into your environment and allow the other scripts
to functiomn correctly 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create a test invoke createtest.sh. 
Invoke without arguments for usage instructions.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure tests, update test.defaults.config, invoke:

iRSG/Tests$:./configure.sh

(note the './' and no space before the script name)
This runs the configure script in the current (iRSG/Tests) directory.
The configure script can be run with a path as an argument, in which case it
will conifgure only those tests found anywhere below the specifed path

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute a test cd to the tests directory and read the instructions 
(in case there are test specfic steps)
Generally just invoke ./runtests.sh in the specific test directory.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!Warning - some tests clear down the database without warning!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
