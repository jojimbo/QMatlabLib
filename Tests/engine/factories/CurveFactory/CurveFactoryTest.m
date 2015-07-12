classdef CurveFactoryTest < matlab.unittest.TestCase
    properties
        factory
        quant_path
        curve_path
    end
    
    methods(TestMethodSetup)
        function createfactory(testcase)
            % Do not add curves to the curve folder here - unless you
            % understand the impact on the tests - do it in the tests 
            % themselves as they have different expectations
            
            testcase.createCurveDir();
            config = testcase.getConfig(testcase.quant_path);
            
            cm = helper.confman;
            cm.use(config);
            
            testcase.factory = engine.factories.CurveFactory();
        end
    end
    
    methods(TestMethodTeardown)
        function restore(testcase)
            % Encourage the factories destructor to execute. Otherwise the
            % file system watcher can keep a lock on the temp directory.
            % This wont cause a test to fail but may generate warnings
            testcase.factory = [];
        end
    end
    
    methods (Test)
        %% This set of tests are executed with an empty curve folder
        function givenNoCurvesThenExpectEmptyCurveList(testcase)
            testcase.verifyEmpty(testcase.factory.list);
        end
        
        function givenNoCurvesThenExpectCurveDoesNotExist(testcase)
            testcase.verifyFalse(testcase.factory.exists('not there'));
        end
        
        function givenNoCurvesThenExpectDoesNotExistException(testcase)
            testcase.verifyError(@() testcase.factory.get('not there'),...
                'BaseFactory:noSuchFile');
        end
    end
    
    methods (Test)
        %% This set of tests are executed with one curve in the folder
        
        function givenOneCurveExpectOneCurve(testcase)
            testcase.verifyEmpty(testcase.factory.list);
                        
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
                        
            testcase.verifyNotEmpty(testcase.factory.list);
        end
        
        function givenOneCurveExpectOneCurveByName(testcase)
            testcase.verifyEmpty(testcase.factory.list);
                        
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
 
            testcase.verifyTrue(strcmp(testcase.factory.list, 'OneCurve'));
        end
        
        function givenOneCurveExpectCurveDoesExist(testcase)
            testcase.verifyEmpty(testcase.factory.list);

            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
 
            testcase.verifyTrue(testcase.factory.exists('OneCurve'));
        end
        
        function givenOneCurveExpectCanGetCurve(testcase)
            testcase.verifyEmpty(testcase.factory.list);
            
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
 
            curve = testcase.factory.get('OneCurve');
            testcase.verifyTrue(strcmp(curve.name, 'One curve'));
        end
        
        function givenOneCurveExpectCurveDoesNotExist(testcase)
            testcase.verifyEmpty(testcase.factory.list);
            
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
 
            testcase.verifyFalse(testcase.factory.exists('not there'));
        end
        
        function givenOneCurveExpectDoesNotExistException(testcase)
            testcase.verifyEmpty(testcase.factory.list);
            
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
 
            testcase.verifyError(@() testcase.factory.get('not there'),...
                'BaseFactory:noSuchFile');
        end
    end
    
    methods (Test)
        %% This set of tests are executed with at least one curve in the folder
        
        % TODO this test does too much
        function givenTwoCurvesExpectCanGetCurveAfterCreated(testcase)
            testcase.verifyEmpty(testcase.factory.list);
                        
            testcase.verifyFalse(testcase.factory.exists('OneCurve'));
            testcase.verifyFalse(testcase.factory.exists('TwoCurve'));
            
            testcase.copyTestFiles('@OneCurve', testcase.curve_path);
            
            testcase.verifyTrue(testcase.factory.exists('OneCurve'));
            testcase.verifyFalse(testcase.factory.exists('TwoCurve'));
            
            testcase.copyTestFiles('@TwoCurve', testcase.curve_path);
                        
            testcase.verifyTrue(testcase.factory.exists('OneCurve'));
            testcase.verifyTrue(testcase.factory.exists('TwoCurve'));
            
            curve = testcase.factory.get('TwoCurve');
            testcase.verifyTrue(strcmp(curve.name, 'Two curve'));
        end
    end
    
    methods %% Helper methods
        function [config] = getConfig(~, quant_path)
            global RCQL_ROOT;
            root = RCQL_ROOT;
            
            config = ['{' ...
                ' "root": "' root '",' ...
                ' "engine": "{root}/SourceCode/+engine",' ...
                ' "quant": "' quant_path '"' ...
                '}'];
        end
        
        function [ result ] = copyTestFiles(~, curve_name, curve_path)
            file_path = fullfile(pwd, 'TestInputFiles');
            
            %% The addition of the '*' is a hack. Without it MATLAB copies
            %  the file within the @OneCurve folder instead of copying the
            %  folder
            curve = fullfile(file_path, [curve_name '*']);
            result = copyfile(curve, curve_path);
            
            if ~exist(fullfile(curve_path, curve_name), 'dir')
                error(['Curve ' curve_name ' was not created!']);
            end
            
            % We need a slight pause for the system to notify the factory
            % that a new curve has been added
            pause(0.01);
        end
        
        function [] = createCurveDir(testcase)
            % Create temporary directory as a root of +quant/+curves that
            % will automatically be cleaned up
            import matlab.unittest.fixtures.TemporaryFolderFixture            
            tempFolder = testcase.applyFixture(TemporaryFolderFixture);
            
            % Add the temporary folder to the path - it will be removed
            % automatically
            import matlab.unittest.fixtures.PathFixture
            testcase.applyFixture(PathFixture(tempFolder.Folder));
            
            testcase.quant_path = fullfile(tempFolder.Folder, '+quant');
            testcase.curve_path = fullfile(testcase.quant_path, '+curves');
        
            % Create <tmp_folder>/+quant/+curves
            mkdir(testcase.curve_path);
        end
    end
end

