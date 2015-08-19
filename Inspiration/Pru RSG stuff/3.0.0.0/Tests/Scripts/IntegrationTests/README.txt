*************************************************
******************** READ ME ******************** 

This document provide instructions for running automated tests using the xunit test framework for MATLAB.

Initial steps:

- Make sure that MATLAB has been started from within the RSG Source folder. The classpath.txt file under the RSG Source folder must have correctly reference the paths to the following libraries:
	- poi-3.7-20101029.jar
	- ojdbc6.jar
	- mds.jar

* If the references to the above libraries are not set correctly, then you won't be able to connect to the database specified in the app.config file. In order to fix this problem, run the following command while at the RSG Source folder:

. fixclasspath.sh

- Navigate one level up from the RSG Source folder and add the xunit folder (and its subfolders) to the path. This can be done by left clickining on the xunit folder and select "Add to Path --> Selected Folder and Subfolders".

- Navigate to the IntegrationTests folder which is found in the following path (using MKS folder structure):
PruRSG/iRSG/Tests/IntegrationTests

- The original integration tests can be found under Regression.Persistence folder (The dot notation will be used from this point forward to indicate subfolders. In this case the Persistence folder is a subfolder of the Regression folder.). Additional regression tests will be added over time and these will exists within individual folders under the Regression folder following the naming convention shown below:

+QCxxxx where xxxx is the number of the QC for which the test was initially a functional test.

Each +QCxxxx folder will have its own app.config file which will drive the test inside that folder. In addition each +QCxxx folder will contain a text file with instructions for the test. The instructions text file will be named "Instructions_QCxxxx.txt", where as above xxxx is the number of the QC for which the test was initially a functional test.

- Update the app.config file within a +QCxxxx folder according to the instructions in that folder. 

- Copy the app.config file under the IntegrationTests folder.

- Run the test from the IntegrationTests folder using the following convention:

	Regression.QCxxxx.Test_QCxxxx

The above command will execute test Test_QCxxxx which exists under the following path with the IntegrationTests folder: Regression/QCxxx

*Note that the test script clears down the database prior to its execution.

*************************************************
*************************************************





