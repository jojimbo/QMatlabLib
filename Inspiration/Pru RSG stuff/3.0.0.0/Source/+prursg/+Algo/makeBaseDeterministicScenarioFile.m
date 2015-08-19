function out = makeBaseDeterministicScenarioFile(baseCurr, sessionDate, algoCurves, timesteps, algoScenarioName, numberFormat)
    %MAKEBASEDETERMINISTICSCENARIOFILE produces the Algo deterministic scenario
    %file LM_Asset_Macro_ScenSet.csv
    %
    % sessionDate is the the date of the earliest Algo timestep(calibration
    % date) in format 'yyyy/mm/dd'
    % algoCurves - the ordered vector of all algo curves 
    % timesteps - an ordered vector of prursg.Engine.Scenario. Timesteps are
    % ordered by date in format 'yyyy/mm/dd'
    
    out = getHeaderRow(algoScenarioName);
        
    % Apparently the process Control Information needs to be repeated for
    % every different timestep
    for i = 1:length(timesteps)
        relativeOffset = prursg.Util.DateUtil.DaysActual(sessionDate, prursg.Util.DateUtil.ReplaceLeapDate(timesteps(i).date)); % in days
        out = [ out processControlInformation(relativeOffset) ];
        out = [ out processTimestep(baseCurr, sessionDate, algoCurves, timesteps(i), numberFormat)]; %#ok<AGROW>
    end
end

function out = processTimestep(baseCurr, sessionDate, algoCurves, timestep, numberFormat)
    relativeOffset = prursg.Util.DateUtil.DaysActual(sessionDate, prursg.Util.DateUtil.ReplaceLeapDate(timestep.date)); % in days
    out = '';        
    
    for i = 1:length(algoCurves)
        out = [ out ...
                processRisk(baseCurr, relativeOffset, algoCurves(i), timestep.expandedUniverse, numberFormat) ...
        ]; %#ok<AGROW>
    end        
end

function out = processControlInformation(relativeOffset)
%    out = [ 
%        ',,,,,scenario_index,0,,,,,,absolute,Term/Time,0' endl() ...
%        ',,,,,,,,,,,,,0,0' endl() ...
%        ',,,,,scenario_indicator,0,,,,,,absolute,Term/Time,0' endl() ...
%        ',,,,,,,,,,,,,0,0' endl() ...
%    ];
    out = [ 
        sprintf(',,,,,scenario_index,%d,,,,,,absolute,Term/Time,0', relativeOffset) endl() ...
        ',,,,,,,,,,,,,0,0' endl() ...
        sprintf(',,,,,stochastic_indicator,%d,,,,,,absolute,Term/Time,0', relativeOffset) endl() ...
        ',,,,,,,,,,,,,0,0' endl() ...
    ];

end

function out = processRisk(baseCurr, relativeOffset, algoCurve, expandedUniverse, numberFormat)
    switch algoCurve.type
       case { 'INDEX' }            
           out = processEquity(relativeOffset, algoCurve, algoCurve.getDeterministicValue(expandedUniverse), numberFormat);
       case { 'ZERO_CURVE' }
           out = processCurve(relativeOffset, algoCurve, algoCurve.getDeterministicValue(expandedUniverse), expandedUniverse(algoCurve.name), numberFormat);
       case 'FX_RISK_FACTOR'
           out = processFx(baseCurr, relativeOffset, algoCurve, algoCurve.getDeterministicValue(expandedUniverse), numberFormat);
       case 'FX_RATE'
           % do nothing - it is accounted for by the FX_RISK_FACTOR code
           out = '';
       case 'VOL'
           out = processVol(relativeOffset, algoCurve, expandedUniverse(algoCurve.name), numberFormat);
       case 'SVOL'
           out = processSvol(relativeOffset, algoCurve, expandedUniverse(algoCurve.name), numberFormat);           
       case 'CREDIT_SPREAD'
           out = processCreditSpread(relativeOffset, algoCurve, expandedUniverse, numberFormat);
       otherwise
            error('should not get here!');            
   end
end


function out = processEquity(relativeOffset, risk, value, numberFormat)    
    id = risk.makeStoCurve();
    out = [ 
        sprintf(',,,,,%s,%d,,,,,,absolute,Term/Time,0', id, relativeOffset) endl() ...
        sprintf([',,,,,,,,,,,,,0,' numberFormat], value) endl() ...
    ];
end

function out = processFx(baseCurr, relativeOffset, risk, values, numberFormat)
    id = risk.makeStoCurve();
    fxRateId = ['FX_' baseCurr '/' risk.currency];
    out = [ 
        sprintf(',,,,,%s,%d,,,,,,absolute,Term/Time,0', id, relativeOffset) endl() ...
        sprintf([',,,,,,,,,,,,,0,' numberFormat], values(1)) endl() ...
        sprintf(',,,,,%s,%d,,,,,,absolute,Term,', fxRateId, relativeOffset) endl() ...
        sprintf([',,,,,,,,,,,,,0,' numberFormat], values(1)) endl() ...            
    ];
end

function out = processCurve(relativeOffset, risk, values, dataSeries, numberFormat)
    id = risk.makeStoCurve();
    out = [ sprintf(',,,,,%s,%d,,,,,,absolute,Term,', id, relativeOffset) endl()];    
    terms = dataSeries.axes(1).values;
    for i = 1:length(values)
        term = floor(terms(i) * 365);
        out = [ out sprintf([',,,,,,,,,,,,,%d,' numberFormat], term, values(i)) endl() ]; %#ok<AGROW>
    end    
end

function out = processVol(relativeOffset, algoCurve, dataSeries, numberFormat)
    id = algoCurve.makeStoCurve();
    moneyness = dataSeries.axes(1);
    term = dataSeries.axes(2);
    values = dataSeries.values{1};   
    out = [ sprintf(',,,,,%s,%d,,,,,,absolute,Moneyness/Option Term,', id, relativeOffset) ...
            toCsv(floor(term.values .* 365), @(x) num2str(x, numberFormat)) ',' endl() ];
    for i = 1:numel(moneyness.values)        
        out = [ out sprintf(',,,,,,,,,,,,,%d,', moneyness.values(i)) ...
                toCsv(values(i, :), @(x) num2str(x, numberFormat)) endl() ];  %#ok<AGROW>
    end
end

function out = processSvol(relativeOffset, algoCurve, dataSeries, numberFormat)
    id = algoCurve.makeStoCurve();
    moneyness = dataSeries.axes(1);    
    term = dataSeries.axes(2);
    tenor = dataSeries.axes(3);        
    values = dataSeries.values{1}; 
    out = '';
    for i = 1:numel(moneyness.values)
        curveName =  [ id '_' num2str(moneyness.values(i)) ];
        out = [ out sprintf(',,,,,%s,%d,,,,,,absolute,Underlying Term/Option Term,', curveName, relativeOffset) ...
                toCsv(floor(tenor.values .* 365), @(x) num2str(x, numberFormat)) ',' endl() ]; %#ok<AGROW>
        for j = 1:numel(term.values)            
            out = [ out sprintf(',,,,,,,,,,,,,%d,', floor(term.values(j) * 365)) ...
                    toCsv(values(i, j, :), @(x) num2str(x, numberFormat)) endl() ];  %#ok<AGROW>            
        end
    end    
end

function out = processCreditSpread(relativeOffset, algoCurve, expandedUniverse, numberFormat)
    id = algoCurve.algoName;
    values = algoCurve.getDeterministicValue(expandedUniverse); % 2d matrix term/rating
    
    out = [ sprintf(',,,,,%s,%d,,,,,,absolute,Term/Credit State,', id, relativeOffset) ...
            algoCurve.getRatingsList(',') ',' endl() ];
        
    termAxis = algoCurve.getCreditSpreadTermAxis(expandedUniverse);
    for i = 1:numel(termAxis.values)
        term = floor(termAxis.values(i) * 365);
        out = [ out sprintf(',,,,,,,,,,,,,%d,', term) ...
                toCsv(values(i, :), @(x) num2str(x, numberFormat)) endl() ];  %#ok<AGROW>
    end
end

function str = toCsv(values, to_str)
    str = '';
    for i = 1:numel(values)        
        str = [ str to_str(values(i)) ',' ]; %#ok<AGROW>
    end
    str = str(1:end - 1); % crop the last ','
end

function str = dbl2str(dbl)
    str = num2str(dbl, '%.15E');
end

function out = endl()
    out = 10; % '\n'
end

function header = getHeaderRow(algoScenarioName)
    header = ['ScenSet,SetName,ScenName,ScenProb,ScenColor,ScenVar,startTime,ScenAttr,Time Evolution from Trigger,Time Evolution to Trigger,Trigger Holder,Scenario Shift Rule,ScenType,ScenValue' endl() ...
              sprintf(',%s,%s_1,1,#C0504D', algoScenarioName, algoScenarioName) endl() ];

end
