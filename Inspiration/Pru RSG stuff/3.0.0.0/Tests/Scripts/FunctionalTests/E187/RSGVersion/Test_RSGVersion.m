%% Test_RSGVersion
%
% SUMMARY:
% 	Test the new RSGVersion singleton
%%

function test_suite = Test_RSGVersion() %#ok<STOUT>
	 % The first test must return an instance of initTestSuite
	disp('Initialising Test_RSGVersion')
	initTestSuite;
	disp('Executing Test_RSGVersion')
end

function setup() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

function teardown() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
    removeVersionStore();
    
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
    
    setVersion(instance.v0_0_0_0);
    setSchemaVersion(instance.v0_0_0_0);
end

%%
%% Schema version tests
%%

function Test_ValidateRSGSchemaVersions()	%#ok<DEFNU> % Test names must be prefixed with test
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
        
	assertEqual('0.0.0.0', instance.v0_0_0_0);
    assertEqual('2.3.0.0', instance.v2_3_0_0);
    assertEqual('3.0.0.0', instance.v3_0_0_0);

	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetRSGSchemaVersions()	%#ok<DEFNU> % Test names must be prefixed with test
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
        
    
    function assignv0_0(); instance.v0_0_0_0 = '1.2.3.4'; end
    function assignv2_3(); instance.v2_3_0_0 = '1.2.3.4'; end
    function assignv3_0(); instance.v3_0_0_0 = '1.2.3.4'; end

    function assign(f)
        assertExceptionThrown(f,...
            'MATLAB:class:SetProhibited', ... 
            'We expect an exception as the version string is protected - const')
    end
    
    assign(@() assignv0_0());
    assign(@() assignv2_3());
    assign(@() assignv3_0());

	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_GetRSGSchemaVersion_unset()	%#ok<DEFNU> % Test names must be prefixed with test
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    % Never been set so should default to 0.0.0.0
    instance = VersionInfo.instance();    
	assertEqual(instance.RSGSchemaVersion, instance.v0_0_0_0);

	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetGetRSGSchemaVersion()	%#ok<DEFNU> % Test names must be prefixed with test
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
    
    instance.RSGSchemaVersion = instance.v3_0_0_0;    
	assertEqual(instance.RSGSchemaVersion, instance.v3_0_0_0);
    
    instance.RSGSchemaVersion = instance.v0_0_0_0;    
	assertEqual(instance.RSGSchemaVersion, instance.v0_0_0_0);
    
    instance.RSGSchemaVersion = instance.v2_3_0_0;    
	assertEqual(instance.RSGSchemaVersion, instance.v2_3_0_0);    
    

	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGSchemaVersionA() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
       
    verString = '1..3.4'; % Bad version - should be 1.2.3.4
    setSchemaVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGSchemaVersionB() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '2.3'; % Bad version - should be 1.2.3.4
    setSchemaVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGSchemaVersionC() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '9.9.9.9'; % Bad version - format is ok but not a valid version
    setSchemaVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGSchemaVersionD() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '0.0.0.1'; % Bad version - format is ok but not a valid version
    setSchemaVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end


%%
%% RSG version tests
%%

function Test_GetRSGVersion_unset()	%#ok<DEFNU> % Test names must be prefixed with test
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
    
    removeVersionStore();
    
	assertEqual(RSGVersion(), instance.v0_0_0_0);

	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetGetRSGVersion_unset() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance();
    
    removeVersionStore();
    
    verString = '1.2.3.4'; % Good version
    instance.RSGVersion = verString;
    
    assertEqual(RSGVersion(), verString)
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGVersion_unset() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '1,2.3.4'; % Bad version - note the comma
    setVersionExpectException(verString);
    
   	disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGVersionA() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '1..3.4'; % Bad version - should be 1.2.3.4
    setVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGVersionB() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '1.3.4'; % Bad version - should be 1.2.3.4
    setVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGVersionC() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '.1.3.4'; % Bad version - should be 1.2.3.4
    setVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetMalformedRSGVersionD() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    
    verString = '1.11.3.4'; % Bad version - should be 1.2.3.4
    setVersionExpectException(verString);
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_SetEmptyRSGVersion() %#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
       
    verString = ''; % Bad version - empty  
    setVersionExpectException(verString);   
    
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end


%% Utils

function setSchemaVersion(verString)
    import prursg.Version.*;
    
    instance = VersionInfo.instance();  
    instance.RSGSchemaVersion = verString;
end

function setSchemaVersionExpectException(verString)
    assertExceptionThrown(@() setSchemaVersion(verString),...
        'VersionInfo:parseVersion:MalformedInput', ... 
        'We expect an exception as the version string is malformed')
end

function setVersion(verString)
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 
    instance.RSGVersion = verString;
end

function setVersionExpectException(verString)
    assertExceptionThrown(@() setVersion(verString),...
        'VersionInfo:parseVersion:MalformedInput', ... 
        'We expect an exception as the version string is malformed')
end

function removeVersionStore()
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 
    
    verFile = instance.RSGVersionFilePath;
    if exist(verFile, 'file')
        delete(verFile);
    end
end

