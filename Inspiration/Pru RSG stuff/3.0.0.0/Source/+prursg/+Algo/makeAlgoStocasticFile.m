function makeAlgoStocasticFile(fid, baseCurr, simTotal,offsetDate, algoCurves, noRiskScenario, stoValue, scenarioType, stoScenarios, setName, scenarioPrefix, numberFormat)
    %MAKEALGOSTOCASTICFILE produces the Algo monte carlo scenario
    %file SCEN_LM_GENERIC.csv
    %
    % algoCurves - the ordered vector of all algo curves 
    % stoValues - cell arrays of all the monte carlo scenarios
    % algoScenarioName - Scenario set name
    
    isShockedBase = 0;
    switch scenarioType    
        case {int32(prursg.Engine.ScenarioType.WhatIfBase)}
            isShockedBase = 1;
    end
    
    scenarioIndex = 0;  
    stochasticIndicator = isShockedBase;
    %process base scenario
    getHeaderRow(fid,setName, scenarioPrefix);
    serialiseCurve(algoCurves);
    processTimestep(fid, baseCurr, offsetDate, algoCurves, scenarioIndex, stochasticIndicator, numberFormat);
    
    stochasticIndicator = 2;
    %process no risk scenario        
    if ~isempty(noRiskScenario)
        fprintf(fid,',,%snoriskscr,0,#C0504D\n', scenarioPrefix);
        noRisks= getNoRiskCurves(algoCurves,noRiskScenario.expandedUniverse);
        scenarioIndex = scenarioIndex + 1;
        processTimestep(fid, baseCurr, offsetDate, noRisks, scenarioIndex, stochasticIndicator, numberFormat);        
    end
    
    %process stochastic scenario
    for i = 1:simTotal 
        scenarioName = prursg.Algo.AlgoUtil.ConvertScenarioName(scenarioType, stoScenarios, i, scenarioPrefix);
        fprintf(fid,',,%s,1,#C0504D\n', scenarioName);        
        getStocasticValues(algoCurves, i , stoValue);
        scenarioIndex = scenarioIndex + 1;
        processTimestep(fid, baseCurr, offsetDate, algoCurves, scenarioIndex, stochasticIndicator, numberFormat);
   end
end


function getStocasticValues(algoCurves, rowId, stoValue)
%GETSTOCASTICVALUES get the stocastic scenarios row from cell array
    for i = 1: length(algoCurves)
        algoCurves(i).dataSeries.values{1}=stoValue{1}{algoCurves(i).indices}(rowId,:);
    end
end



function out = processTimestep(fid, baseCurr, offsetDate, algoCurves, scenarioIndex, stochasticIndicator, numberFormat)
    
    out = '';
    
    processControlInformation(fid, scenarioIndex, stochasticIndicator);
    
    for i = 1:length(algoCurves)
        processRisk(fid, baseCurr, offsetDate, algoCurves(i), numberFormat);
    end
end

function processControlInformation(fid, scenarioIndex, stochasticIndicator)
    fprintf(fid, ',,,,,scenario_index,0,,,,,,absolute,Term/Time,0\n,,,,,,,,,,,,,0,%d\n', scenarioIndex);
    fprintf(fid, ',,,,,stochastic_indicator,0,,,,,,absolute,Term/Time,0\n,,,,,,,,,,,,,0,%d\n', stochasticIndicator);
end

function processRisk(fid, baseCurr, offsetDate, algoCurve, numberFormat)
    switch algoCurve.type
       case { 'INDEX' }            
           processEquity(fid, offsetDate, algoCurve, numberFormat);
       case { 'ZERO_CURVE' }
           processCurve(fid, offsetDate, algoCurve, numberFormat);
       case 'FX_RISK_FACTOR'
           processFx(fid, baseCurr, offsetDate, algoCurve, numberFormat);       
       case 'VOL'
           processVol(fid, offsetDate, algoCurve, numberFormat);
       case 'SVOL'
           processSvol(fid, offsetDate, algoCurve, numberFormat);           
       case 'CREDIT_SPREAD'
           processCreditSpread(fid, offsetDate, algoCurve, numberFormat);
       case 'FX_RATE';
       otherwise
            error('Risk Driver Type is not recognised! %s',algoCurve.type);            
   end
end


function processEquity(fid, relativeOffset, algoCurve, numberFormat)        
    fprintf(fid, [',,,,,%s,%d,,,,,,absolute,Term/Time,0\n,,,,,,,,,,,,,0,' numberFormat '\n'], algoCurve.algoName, relativeOffset, algoCurve.dataSeries.values{1});
end

function processFx(fid, baseCurr, relativeOffset, algoCurve, numberFormat)
    id = algoCurve.algoName();
    fprintf(fid, ',,,,,%s,%d,,,,,,absolute,Term/Time,0\n', id, relativeOffset);
    fprintf(fid, [',,,,,,,,,,,,,0,' numberFormat '\n'], algoCurve.dataSeries.values{1});
end

function processCurve(fid, relativeOffset, algoCurve, numberFormat)
    id = algoCurve.algoName;
    format = ',,,,,%s,%d,,,,,,absolute,Term\n';
    fprintf(fid, format, id, relativeOffset);
    
    format = repmat([',,,,,,,,,,,,,%d,' numberFormat '\n'],1, length(algoCurve.dataSeries.values) );        
    
    terms = algoCurve.dataSeries.axes(1).values;
    term = floor(terms .* 365);
    values = algoCurve.dataSeries.values{1};
    
    values = [term; values];
    values = reshape(values, 1, []);
    
    fprintf(fid, format, values);
end

function processVol(fid, relativeOffset, algoCurve, numberFormat)
    id = algoCurve.algoName;
    dataSeries=algoCurve.dataSeries;
    moneyness = dataSeries.axes(1);
    term = dataSeries.axes(2);
    values = dataSeries.values{1};   
    
    format = [ ',,,,,%s,%d,,,,,,absolute,Moneyness/Option Term', repmat(',%d', 1, size(term.values, 2)) '\n'];
    fprintf(fid, format, id, relativeOffset, floor(term.values .* 365));
        
    format = [',,,,,,,,,,,,,%d' repmat([',' numberFormat], 1, size(values, 2)) '\n'];
    for i = 1:numel(moneyness.values)  
        fprintf(fid, format, moneyness.values(i), values(i, :));        
    end
end

function processSvol(fid, relativeOffset, algoCurve, numberFormat)
    id = algoCurve.algoName;
    dataSeries=algoCurve.dataSeries;
    moneyness = dataSeries.axes(1);    
    term = dataSeries.axes(2);
    tenor = dataSeries.axes(3); 
    %convert from series to cube
    values=reshape(dataSeries.values{1}, ...
                           [  length(moneyness.values)...
                            length(term.values) ...
                               length(tenor.values)]);
    
    values=squeeze(values); %remove single dimension from cube
    svol= [(floor(term.values.*365))' values'] ;
    svol=reshape(svol', 1, []);
    for i = 1:numel(moneyness.values)
        format = [',,,,,%s,%d,,,,,,absolute,Underlying Term/Option Term' repmat(',%d', 1, size(tenor.values, 2)), '\n'];
        fprintf(fid, format, id, relativeOffset, floor(tenor.values.*365));
        
        format = [',,,,,,,,,,,,,%d' repmat([',' numberFormat], 1, size(values, 2)) '\n'];
        format=repmat(format,1,size(values,1));
        fprintf(fid, format,svol);
    end    
end

function processCreditSpread(fid, relativeOffset, algoCurve, numberFormat)
    id = algoCurve.algoName;
    value = algoCurve.dataSeries.values{1}; % 2d matrix term/rating
    values=algoCurve.initCreditSpread(value);
    
    out = [ sprintf(',,,,,%s,%d,,,,,,absolute,Term/Credit State,', id, relativeOffset) ...
            algoCurve.getRatingsList(',') '\n' ];
        
    fprintf(fid, out);
        
    termAxis = algoCurve.dataSeries.axes(1); 
    format = [',,,,,,,,,,,,,%d' repmat([',' numberFormat], 1, size(values, 2)) '\n'];
    for i = 1:numel(termAxis.values)
        term = floor(termAxis.values(i) * 365);
        fprintf(fid, format, term, values(i, :));        
    end
end

function getHeaderRow(fid,setName, scenarioPrefix)
    header = ['ScenSet,SetName,ScenName,ScenProb,ScenColor,ScenVar,startTime,ScenAttr,Time Evolution from Trigger,Time Evolution to Trigger,Trigger Holder,Scenario Shift Rule,ScenType,ScenValue\n' ...
        ',%s, %sbase,0,#C0504D \n'];
    fprintf(fid, header,setName,scenarioPrefix);

end


function serialiseCurve(algoCurves)
    for i = 1:numel(algoCurves)
        algoCurves(i).dataSeries.values{1}=algoCurves(i).dataSeries.serialise();
    end
end

% converts scenario expanded universe to chunk format

function risks = getNoRiskCurves(risks, expandedUniverse)
    import +prursg.Util.*;

    for i = 1:numel(risks)
        if ~strcmp(risks(i).type, 'FX_RATE')
            risks(i).dataSeries.values{1}=expandedUniverse(risks(i).name).serialise();
        end
    end
    

end



