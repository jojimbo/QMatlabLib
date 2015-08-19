function TestMakeAlgoCurveList()
    clc;
    clear;
    
    filePath = fullfile('+prursg','+Test', '+UseCase', 'usd_ye10_base_v3.xml');
    modelFile = prursg.Xml.ModelFile(filePath, false); 
    risks = modelFile.riskDrivers;
    %disp('risks');
    %for i = 1:numel(risks)
    %    fprintf('%d %s\n', i, risks(i).name);
    %end
    
    srisks = [ risks(1:3) risks(11:17) risks(24) risks(49) ];
    %srisks = risks;
    disp('srisks');
    for i = 1:numel(srisks)
        fprintf('%d %s\n', i, srisks(i).name);
    end
    
    testAlgoCurveList(srisks, modelFile.basecurrency);
    
    
    
end

function testAlgoCurveList(risks, basecurrency)
    algoCurveList = prursg.Algo.AlgoCurve.makeAlgoCurveList(risks, basecurrency);
    
    disp('curves');
    for i = 1:numel(algoCurveList)
        disp(algoCurveList(i).toString());
    end
end
