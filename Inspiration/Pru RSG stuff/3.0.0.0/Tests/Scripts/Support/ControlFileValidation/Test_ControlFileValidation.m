%% Test_ControlFileValidation
%
% SUMMARY:
% 	Validate the RSG input XML control file against the schema
%%

function test_suite = Test_ControlFileValidation()	
    disp('InitialisingTest_ControlFileValidation')
	initTestSuite;
	disp('Executing Test_ControlFileValidation')
end

function Test_ControlFileValidation2()
diary validationOutput.txt;
disp('Starting test: "ControlFileValidation()"...')

	import prusg.*; 
    import testutil.* 
    
    flag = true;
    
    inputXMLFolder = TestUtil.GetConfigValue('InputFolderPath');
    filesToValidate = dir(fullfile(inputXMLFolder, '*.xml'));
    
    for i = 1:length(filesToValidate)
        disp(['Starting validation of file: ' filesToValidate(i).name]);
        [valid errorMessage] = schemaValidation(fullfile(inputXMLFolder,filesToValidate(i).name));
        
        if ~isempty(errorMessage)
            disp(['The file ' filesToValidate(i).name ' does not conform to the schema. The error message is: ' errorMessage]);
            flag = false;
        else
            disp(['Validation completed successfully of file: ' filesToValidate(i).name]);
        end
    end
    
    assertTrue(flag);
    
    disp('Test "ControlFileValidation()" has completed.')
           
    diary off;
end

function [valid errorMessage] = schemaValidation(xmlFile)

    import java.io.*;
    import javax.xml.transform.Source;
    import javax.xml.transform.stream.StreamSource;
    import javax.xml.validation.*;
    import testutil.* 
    
    valid = true;
    errorMessage = [];
    
    try
        factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
        RSGRoot = TestUtil.GetConfigValue('RSGRoot');
        schemaLocation = File(fullfile(RSGRoot, 'Schemas', 'RSGSchema.xsd'));
        schema = factory.newSchema(schemaLocation);
        validator = schema.newValidator();
        source = StreamSource(xmlFile);
        validator.validate(source);
    catch e
        valid = false;
        errorMessage = e.message;
    end

end
