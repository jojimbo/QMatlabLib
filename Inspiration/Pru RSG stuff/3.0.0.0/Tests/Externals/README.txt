This directory contains external libraries and models i.e. things that are
used by the RSG or the tests but are maintained externally

The intention behind adding Pillar I check-pointed files to Externals/Inputs
and External/Models was to provide some certainty and repeatability during
development and test (by using a well known set of model and input files), but
also to simply the setup for automated testing and reduce errors by
eliminating manual steps as much as possible.

This is still the intention and changes to the PI checkpoint folders should
be avoided - ***It should be possible to get the checkpoint directly from the
Pillar I tree and produce the same results***.

==============================================================================
Change log below here
==============================================================================


RSG v3.0.0.0 Release Candidate (RC)  7 - 2012-11-09 
---------------------------------------------------

This is a cumulative between v3.0.0.0 RC1 and RC7.

Backgrouod
----------

The P1_BL4_1_0_13_Revision_1.20 checkpoint was used to create a new baseline
for RSG v2.7.0 however, there were two problems with the checkpoint:

1) Some of the files contained broken references to base scenarios (see
below); these files were modified but not committed to MKS.

2) The Source/prursg folder did not contain the +Converter folder; required
following its introduction in RSG v2.7.0 to control the number of sf in the
RSG output

llwsolv109:/data/riskcare/x1200227/sandboxes$ ls -l P1_BL4_1_0_13_Revision_1.20/Source/prursg/
total 12
drwxr-sr-x 3 x1200227 riskcare 4096 Oct  2 16:55 +Bootstrap
drwxr-sr-x 3 x1200227 riskcare 4096 Oct  2 16:55 +Model
-rw-r--r-- 1 x1200227 riskcare  158 Oct  2 16:55 project.pj



In order to have the automated tests work out of the box we requested Pillar
I provide a new checkpoint which included the fixed control files and the
+Converter folder. 
Rather than branch at the 1.20 checkpoint Pillar I provided
a new checkpoint (BL4_1_0_18_Revision_1.24) with the assurance that the only
changes were in documentation.

To complicate things further, the +Converters folder in the 1.24 checkpoint
did not include the S2dValueConveter; required only because it had been
mistakenly used in the production of the 2.7.0 baseline. The missing converter
was committed to iRSG/Tests/Externals (as illustrated below) 

llwsolv109:/data/riskcare/x1200227/sandboxes$ ls -l
trunk/iRSG/Tests/Externals/Models/BL4_1_0_18_Revision_1.24/+Converter/
total 12
-r--r--r-- 1 x1200227 riskcare 216 Nov  6 13:31 NoneValueConverter.m
-rw-r--r-- 1 x1200227 riskcare 690 Nov  7 11:22 project.pj
-r--r--r-- 1 x1200227 riskcare 997 Nov  7 11:18 Sd2ValueConverter.m


Problem
-------

The 1.24 checkpoint differed in more than just documentation. Both the models
and the XML control files differed e.g. at least one model contained a defect
which caused a runtime error but also the number of simulations and scenario
id was different in Test19; this is the result of a very brief analysis, the
full extend of the changes is not known.

Regression tests failed both due to broken models but also due to differences
in output files. 

Solution
--------

The 1.24 checkpoint was used in the generation of the functional test results;
this does not present a problem as all tests completed successfully; this
includes comparisons with a RSG v2.7.0, P1 1.20 checkpoint; note the
functional tests used Pillar I hand crafted control file.

Regression tests will be rerun using the 1.20 checkpoint. The control files
will have the references to base fixed and the +Converter folder will be added.
 
**Therefore note:

1) Neither the 1.20 or the 1.24 checkpoints in the Externals directory are 'pure'**

2) The what-if and CS control files (24, 25, 31, 32) in
P1_BL4_1_0_13_Revision_1.20 and BL4_1_0_18_Revision_1 have been modified to
correctly reference the base scenarios.
 
3) BL4_1_0_18_Revision_1.24 is broken and should not be used.

