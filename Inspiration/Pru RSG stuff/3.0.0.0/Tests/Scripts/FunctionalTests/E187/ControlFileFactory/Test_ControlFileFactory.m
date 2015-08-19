%% Test_ControlFileFactory
%
% SUMMARY:
% 	Test construction of control files
%%

function test_suite = Test_ControlFileFactory() %#ok<STOUT>
	% The first test must return an instance of initTestSuite
	disp('Initialising Test_ControlFileFactory')
	initTestSuite;
	disp('Executing Test_ControlFileFactory')
end

function setup() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

function teardown() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

%%
%% Tests
%%

function Test_ControlFileFactoryv2_3_0_0A()	%#ok<DEFNU>
	fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config');    

    createControlFile('Test40.xml', 'prursg.Xml.ControlFile.ControlFilev2_3_0_0');
   
	fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileFactoryv2_3_0_0B()	%#ok<DEFNU>
	fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
	ConfigurationManager.setConfigFileName('app.config'); 
   
	createControlFile('Test19.xml', 'prursg.Xml.ControlFile.ControlFilev2_3_0_0');
    
	fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileFactoryv3_0_0_0A()	%#ok<DEFNU>
	fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('local.app.config');    

    createControlFile('Test40_v3.0.0.0.xml', 'prursg.Xml.ControlFile.ControlFilev3_0_0_0');
    
	fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

%%
%% Test utils below here
%%

function createControlFile(controlFile, expected_type)
    import prusg.*;
	import testutil.*;
    inputXMLFolder = TestUtil.GetConfigValue('InputFolderPath');
    control_file = fullfile(inputXMLFolder, controlFile);
    controlFile = prursg.Xml.ControlFile.ControlFileFactory.create(control_file);    
    assertTrue(isa(controlFile, expected_type));
end
