The tests in this directory need to be reviewed.

The DAO populatData method should be used not populatDataContent. The former is a base class method which calls additional methods.

The tests were written to test axis value ordering but this functionlaity is implicitly tested by the QC2497 tests (see the tests that write and read to/from the MDS)

These tests are retained as it would be useful to have explicit axis ordering tests - when we have the time to fix these...
