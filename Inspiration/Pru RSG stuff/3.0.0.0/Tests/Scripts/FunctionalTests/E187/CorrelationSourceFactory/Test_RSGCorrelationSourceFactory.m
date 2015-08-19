%% Test_RSGCorrelationSourceFactory
%
% SUMMARY:
% 	Test the correlation source factory
%%

function test_suite = Test_RSGCorrelationSourceFactory()
	 % The first test must return an instance of initTestSuite
	disp('Initialising Test_RSGCorrelationSourceFactory')
	initTestSuite;
	disp('Executing Test_RSGCorrelationSourceFactory')
end

function setup() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

function teardown() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

%%
%% v2.3.0.0 schema tests
%%

function Test_Constructv2_3_0_0XLS()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes no difference in the v2.3.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource(instance.v2_3_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.XLS,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv2_3_0_0ControlFile()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes no difference in the v2.3.0.0 schema
    constructSource(instance.v2_3_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile,... % not used but benign
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv2_3_0_0None()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes no difference in the v2.3.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource(instance.v2_3_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.None,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

%%
%% v0.0.0.0 schema tests
%%
%% The default without setting the schema version

function Test_Constructv0_0_0_0XLS()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes no difference in the v0.0.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource(instance.v0_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.XLS,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv0_0_0_0ControlFile()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 
    
    % The correlation source makes no difference in the v0.0.0.0 schema
    constructSource(instance.v0_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile,... % not used but benign
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv0_0_0_0None()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes no difference in the v0.0.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource(instance.v0_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.None,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv0_0_0_0XLS_implicit()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;

    % The correlation source makes no difference in the v0.0.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource([],...% Rely on default initialisation
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.XLS,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv0_0_0_0ControlFile_implicit()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;

    % The correlation source makes no difference in the v0.0.0.0 schema
    constructSource([],...% Rely on default initialisation
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile,... % not used but benign
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv0_0_0_0None_implicit()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;

    % The correlation source makes no difference in the v0.0.0.0 schema
    % Therefore even though ans XLS source has been specified, a
    % ControlFile source will be constructed 
    constructSource([],... % Rely on default initialisation
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.None,... % show that this is not used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

%%
%% v3.0.0.0 schema tests
%%

function Test_Constructv3_0_0_0XLS()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes a difference in the v3.0.0.0 schema
    constructSource(instance.v3_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.XLS,...  % show that this is used
        'prursg.CorrelationMatrix.CorrelationMatrixXlsSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv3_0_0_0ControlFile()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes a difference in the v3.0.0.0 schema
    constructSource(instance.v3_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.ControlFile,...  % show that this is used
        'prursg.CorrelationMatrix.CorrelationMatrixControlFileSource');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

function Test_Constructv3_0_0_0None()	%#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...'])

	import prusg.*;
	import testutil.*;
    import prursg.Version.*;
    
    instance = VersionInfo.instance(); 

    % The correlation source makes a difference in the v3.0.0.0 schema
    constructSource(instance.v3_0_0_0,...
        prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.None,... % show that this is used
        'double');
    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end

%%
%% Utils
%%

function constructSource(schema_ver, source_type, expected_type)
    if ~isempty(schema_ver)
        % First set the schema version
        setSchemaVersion(schema_ver);
    end
    
    mcf = MockControlFile();
    mcf.correlationMatrixSource = source_type; % The source that should be constructed
    mcf.controlFilePath = '/foo/bar/baz';
    source = prursg.CorrelationMatrix.CorrelationMatrixSourceFactory.create(mcf);

    assertTrue(isa(source, expected_type),...
        'The factory did not return an instance of the expected class');
end

function setSchemaVersion(verString)
    import prursg.Version.*;
    
    instance = VersionInfo.instance();    
    instance.RSGSchemaVersion = verString;
end