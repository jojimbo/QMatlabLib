The test as configured will fail as the Pillar I 1.20 checkpoint does not
contain the +Converter directory. Until a new checkpoint is obtained from
Pillar I the Tests/Externals/Models/RSGMoldels/+Converter folder should be copied
into the Tests/Externals/Models/P1_BL4_1_0_13_Revision_1.20 folder.

This test does not currently clear down the database and therefore rerunning
the test will cause an error. To clear the DB invoke the following commands
AFTER running the testsetup.sh scripts

db = prursg.Db.DbFacade()
db.clearTables

