function TestWriteBackCalibrationInfo()
    clear;
    clc;

    import prursg.Xml.*;

    fileName = fullfile('+prursg','+Test', '+UseCase', 'T0 base run test.xml');
    %modelFile = ModelFile(fullfile('+prursg','+Test', '+Xml', 'new-model-file.xml'));
    %modelFile = ModelFile('model-file.xml');
    modelFile = ModelFile(fileName, true);
    risks = modelFile.riskDrivers;
    assert(size(modelFile.correlationMatrix, 1) == 23);
    assert(size(modelFile.correlationMatrix, 2) == 23);
    
    testJavaImport(fileName, modelFile);
    testMergeBack(risks, modelFile);
end

function testJavaImport(fileName, modelFile)
    javaModelFile = prursg.Xml.ModelFile(fileName);
    assert(isequal(javaModelFile.correlationMatrix, modelFile.correlationMatrix));
end

function testMergeBack(risks, modelFile) 

    fx = risks(8);
    fx.model.sigma = 14;
    modelFile.correlationMatrix = magic(length(modelFile.correlationMatrix));
    modelFile.merge();

    str = modelFile.toString();
    fileName = [ tempname() '.xml'];
    fid = fopen(fileName, 'w');
    fwrite(fid, str);
    fclose(fid);

    modelFile2 = prursg.Xml.ModelFile(fileName);
    fx2 = modelFile2.riskDrivers(8);
    assert(isequal(fx.model.sigma, fx2.model.sigma));

    assert(isequal(modelFile2.correlationMatrix, modelFile.correlationMatrix));
    
    delete(fileName);

end

