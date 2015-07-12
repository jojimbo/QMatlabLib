classdef ParamTest < matlab.unittest.TestCase
    methods (Test)
        function givenNoSpecWhenNotStrictThenNoError(testcase)
            p = engine.util.Param({'foo', 123, 'bar', 'abc'});
            p.strict = false;
            s = p.process;
            
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.foo, IsEqualTo(123));
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(2));
        end
        
        function givenNoSpecWhenStrictThenError(testcase)
            p = engine.util.Param({'foo', 123, 'bar', 'abc'}, {});
            
            testcase.verifyError(@() p.process,...
                'processargs:UnexpectedArgument');
        end
        
        function givenMatchedSpecWhenNotStrictThenCaseSensitiveOverwrite(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('Foo', 123, 'bar', 'abc'), false);
            s = p.process;
            
            % Case sensitive match means Foo != foo and both appear in the
            % output - not recommended
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(s.Foo, IsEqualTo(123));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(2));
        end
        
        function givenMatchedSpecWhenNotStrictThenCaseInsensitiveOverwrite(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('Foo', 123, 'bar', 'abc'), false);
            s = p.processi;
            
            % Case insensitive match means Foo == foo
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.Foo, IsEqualTo(123));
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(2));
        end
        
        function givenMismatchedSpecWhenNotStrictThenCaseSensitiveMerge(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('foo', 456, 'bar', magic(3)), false);
            s = p.process;
            
            % Case sensitive match means Foo != foo and both appear in the
            % output - not recommended
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.foo, IsEqualTo(456));
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(s.Foo, IsEqualTo(123));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(3));
        end
        
        function givenMismatchedSpecWhenNotStrictThenCaseInsensitiveOverwrite(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('foo', 456, 'bar', magic(3)), false);
            s = p.processi;
            
            % Case insensitive match means Foo == foo
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.foo, IsEqualTo(123));
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(2));
        end
        
        function givenMismatchedSpecWhenStrictThenCaseSensitiveError(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('foo', 456, 'bar', magic(3)));
            
            testcase.verifyError(@() p.process,...
                'processargs:UnexpectedArgument');
        end
        
        function givenMismatchedSpecWhenStrictThenCaseInsensitiveOverwrite(testcase)
            % With spec - not strict
            p = engine.util.Param({'Foo', 123, 'bar', 'abc'}, struct('foo', 456, 'bar', magic(3)));
            s = p.processi;
            
            % Case insensitive match means Foo == foo
            import matlab.unittest.constraints.IsEqualTo;
            testcase.verifyThat(s.foo, IsEqualTo(123));
            testcase.verifyThat(s.bar, IsEqualTo('abc'));
            testcase.verifyThat(length(fieldnames(s)), IsEqualTo(2));
        end
        
        function givenEmptySpecEmptyVarargsWhenStrictThenEmptyResult(testcase)
            varargs = {};
            spec = {};
            strict = true;
            param = engine.util.Param(varargs, spec, strict);
            args = param.process;
            
            testcase.verifyEmpty(fieldnames(args));
        end
        
        function givenEmptySpecEmptyVarargsWhenNotStrictThenEmptyResult(testcase)
            varargs = {};
            spec = {};
            strict = false;
            param = engine.util.Param(varargs, spec, strict);
            args = param.process;
            
            testcase.verifyEmpty(fieldnames(args));
        end
    end
end

