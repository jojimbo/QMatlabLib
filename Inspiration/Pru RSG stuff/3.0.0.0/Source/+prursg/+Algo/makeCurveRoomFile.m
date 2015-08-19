function out = makeCurveRoomFile(baseCurr, sessionDate, run_date, algoCurves, timesteps, stoScenario, debug, numberFormat)
    %MAKEBASEDETERMINISTICSCENARIOFILE produces the Algo curve room file
    %risk_drivers.csv
    %
    % sessionDate is the the date of the earliest Algo timestep(calibration
    % date) in format 'yyyy/mm/dd'
    % risks - the ordered vector of all riskdrivers (contracted universe)
    % timesteps - an ordered vector of deterministic prursg.Algo.Scenario. 
    % Timesteps are ordered by date in format 'yyyy/mm/dd'

    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % Some of the template strings have a % character. Make sure if 
    % sprintf has merge arguments, then the % must be escaped to %%.
    % if it has no merge arguments - do NOT escape the %
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %        
    assert(sessionDate == prursg.Util.DateUtil.ReplaceLeapDate(timesteps(1).date));
    out = makeDatePeriodsAndProjectionDate(sessionDate, run_date, timesteps, debug); %And runPeriod as well
    out = [ out makeControlInformationObjects(debug)];
    out = [ out makeCashIndexHeader() ];
    
    
    % enumerate risk_families per currency
    structure = makeCurveStructure(algoCurves); 
    out = [ out make_CURR_riskDrivers(structure, debug) ]; % map<curr, map<family, risk>>   
    %
    out = [ out makeSubsplits(structure, debug) ]; % definitions of CURR_riskfamily_default or CURR_riskfamily_ftse100 curves
    
    %
    out = [ out makeChildCurves(baseCurr, structure, sessionDate, timesteps, stoScenario, debug, numberFormat) ];
    
    out = [ out finishWithFxConversion(baseCurr, keys(structure), debug) ];
end

function out = makeDatePeriodsAndProjectionDate(sessionDate, run_date, timesteps, debug)
    % convention is that the first timestep is the session date - the last
    % is the calculation/projection date
    % the timestep indexes are zero based!
    % DatePeriods
    out = debugInit(debug, [ '# Date Periods and ProjectionDate' endl() ]);
    out = [ out 'BAS,Historical RatesSPEC,Historical RatesSPEC,Historical Rates,DatePeriods,DatePeriods,0,,FALSE,0,FALSE,@Linear,TRUE,%,simple,actual/365' endl()];
    runPeriod = length(timesteps);
    for i = 1:length(timesteps)
        offset = prursg.Util.DateUtil.DaysActual(sessionDate, prursg.Util.DateUtil.ReplaceLeapDate(timesteps(i).date));
        % runPeriod stores the period corresponding to the run_date
        if offset >= prursg.Util.DateUtil.DaysActual(sessionDate, run_date)
            runPeriod = [runPeriod i-1];
        end
        out = [out sprintf('rm_ro,Historical RatesSPEC : Historical Rate Surface,Historical Rate Surface,Historical RatesSPEC,%d,%d', offset, i - 1) endl()]; %#ok<AGROW>
    end
    %ProjectionDate
    out = [out 'BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,Projection date,Projection date,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,' endl()];
    out = [out sprintf('rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,%d', length(timesteps) - 1) endl()];
    
    runPeriod = min(runPeriod);
    %runPeriod
    out = [out 'BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,runPeriod,runPeriod,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,' endl()];
    out = [out sprintf('rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,%d', runPeriod) endl()];
    
    
    
end

function out = makeControlInformationObjects(debug)
    
    % scenario index
    out = debugInit(debug, [ '# Scenario Index and Stochastic Indicator' endl() ]);
    out = [out 'BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,scenario_index,scenario_index,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,' endl()];
    out = [out 'rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,-1' endl()];
    % stochastic indicator
    out = [out 'BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,stochastic_indicator,stochastic_indicator,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,' endl()];
    out = [out 'rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,-1' endl()];
end

    
function out = makeCashIndexHeader()
    out = [ ...
        'BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,cashIndex,cashIndex,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,@sum' endl() ...
        'rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1' endl() ...
    ];
end

function currs = makeCurveStructure(algoCurves)
    % map<currency, map<family, {risk1 risk 2 ...> >
    %     <GBP, <equitycri, <GBP_equitycri_ftse100, GBP_equitycri_ftse350 ...>
    currs = containers.Map();
    for i = 1:length(algoCurves)
        curve = algoCurves(i);
        if ~(currs.isKey(curve.currency))            
            currs(curve.currency) = containers.Map();
        end
        fams = currs(curve.currency);
        family = curve.risk_family;
        if fams.isKey(family)
            fams(family) = [ fams(family) curve ];
        else
            fams(family) = curve;
        end
        currs(curve.currency) = fams; % is this needed? no it is not.
    end
end

function out = make_CURR_riskDrivers(structure, debug)
    out = debugInit(debug, [ endl() '# Currencies_riskDrivers families' endl() ]);
    currencies = keys(structure);
    for i = 1:length(currencies)
        out = [out sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s_riskDrivers,%s_riskDrivers,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', currencies{i}, currencies{i}) endl() ]; %#ok<AGROW>
        families = keys(structure(currencies{i}));
        for j = 1:length(families)
            family = [ currencies{i} '_' families{j} ]; % USD_equitycri, USD_fx ...
            out = [ out ...
                sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', family) endl() ...
            ]; %#ok<AGROW>
        end        
    end
end

function out = makeSubsplits(structure, debug)    
    out = debugInit(debug, [ endl() '# risk drivers subsplit definitions ' endl() ]);
    
    currs = keys(structure);
    for i = 1:length(currs)
        fams = structure(currs{i});
        out = [ out makeFamilySubsplits(currs{i}, fams) ];  %#ok<AGROW>
    end
end

function out = makeFamilySubsplits(currency, families)    
    fams = keys(families);
    out = '';
    for i = 1:length(fams)     
        risks = families(fams{i});        
        familyName = [ currency '_' fams{i} ];
        if ~strcmp(risks(1).type, 'CREDIT_SPREAD')
            for j = 1:length(risks)
                if strcmp(risks(j).type, 'FX_RATE')
                    continue; % apparently this is not a risk factor and has no family etc.
                end
                subsplit = risks(j).makeSubsplit();
                out = [ ...
                    out ...
                    sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', familyName, familyName) endl() ...
                    sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', subsplit) endl() ...
                ]; %#ok<AGROW>
            end
        else
            out = [ out ...
                    sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', familyName, familyName) endl() ...
                ]; %#ok<AGROW>

            for j = 1:length(risks)
                subsplit = risks(j).makeSubsplit();
                out = [ out ...
                    sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', subsplit) endl() ...
                ]; %#ok<AGROW>
            end
        end
    end
end


function out = makeChildCurves(baseCurr, structure, sessionDate, timesteps, stoScenario, debug, numberFormat)
% a separate sto and det curve for each lovely risk factor. for each
% timestep - enumerate curve's values. Timestep dates are relative offsets
% from the session date.    
    out = debugInit(debug, [ endl() '# risk drivers child curve definitions ' endl() ]);
    currs = keys(structure);
    for i = 1:length(currs)
        fams = structure(currs{i});
        families = keys(fams);
        for j = 1:length(families)
            algoCurves = fams(families{j});
            out = [ out makeFamilyRiskFactors(baseCurr, algoCurves, sessionDate, timesteps, stoScenario, debug, numberFormat) ];  %#ok<AGROW>
        end
    end
end

function out = makeFamilyRiskFactors(baseCurr, algoCurves, sessionDate, timesteps, stoScenario, debug, numberFormat)
    import prursg.Algo.*;
    out = '';
    for i = 1:length(algoCurves)
        risk = algoCurves(i);
        if strcmp(risk.type, 'FX_RATE') % this is not a true risk factor - so skip it
            continue;
        end
        
        % the sto and det definitions are common to all rfs
        [split, det, sto ] = risk.makeAllNames();
        out = [ out ...            
            debugInit(debug, [ endl() sprintf('# %s %s', risk.type, risk.name) endl() ]) ...            
            sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', split, split) endl() ...
            sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', det) endl() ...
            sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', sto) endl() ...
        ];  %#ok<AGROW>
        %
        switch (risk.type)
            case { 'INDEX' }  %   , 'VOL', 'SVOL', 'CREDIT_SPREAD'
                out = [out processEquity(risk, sessionDate, timesteps, stoScenario, debug, numberFormat)]; %#ok<AGROW>
            case { 'ZERO_CURVE' }
                out = [out processCurve(risk, sessionDate, timesteps, stoScenario, debug, numberFormat)]; %#ok<AGROW>
            case 'FX_RISK_FACTOR'
                out = [out processFx(baseCurr, risk, sessionDate, timesteps, stoScenario, debug, numberFormat)]; %#ok<AGROW>
            case 'VOL'
                out = [ out processVol(risk, timesteps, stoScenario, debug, numberFormat) ]; %#ok<AGROW>
            case 'SVOL'
                out = [out processSvol(risk, timesteps, stoScenario, debug, numberFormat) ]; %#ok<AGROW>
            case 'CREDIT_SPREAD'
                out = [ out processCreditSpread(risk, timesteps, stoScenario, debug, numberFormat)]; %#ok<AGROW>
            otherwise
                error('should not get here!');
        end
    end    
end

function out = processEquity(algoCurve, sessionDate, timesteps, stoScenario, debug, numberFormat)
    out = makeAlgoIndexDetAndStoCurves(algoCurve, sessionDate, timesteps, stoScenario, debug, numberFormat);
end

% shared by stock indexes and fx rates
function out = makeAlgoIndexDetAndStoCurves(algoCurve, sessionDate,timesteps, stoScenario, debug, numberFormat)    
    [tempUnused, det, sto ] = algoCurve.makeAllNames();
    % the sto curve gets the values from the stoScenario.
    lastTimestep = stoScenario;
    dataSeries = lastTimestep.expandedUniverse(algoCurve.name);
    values = dataSeries.values{1};    
    out = '';
    out = [ out ...
        sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,', sto, sto) endl() ...
        sprintf(['rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,' numberFormat], values(1)) endl() ...
    ];  

    % the det curve gets the values of all timesteps ordered by their
    % relative offset from sessionDate   
    out = [ out sprintf('BAS,Historical RatesSPEC,Historical RatesSPEC,Historical Rates,%s,%s,0,,FALSE,0,FALSE,@Linear,TRUE,%%,simple,actual/365', det, det) endl() ];
    for i = 1:length(timesteps)
        t = timesteps(i);
        offset = prursg.Util.DateUtil.DaysActual(sessionDate, prursg.Util.DateUtil.ReplaceLeapDate(t.date));
        values = t.expandedUniverse(algoCurve.name).values{1};
        out = [ out sprintf(['rm_ro,Historical RatesSPEC : Historical Rate Surface,Historical Rate Surface,Historical RatesSPEC,%d,' numberFormat], offset, values(1)) endl()]; %#ok<AGROW>
    end
   % sprintf('rm_ro,Historical RatesSPEC : Historical Rate Surface,Historical Rate Surface,Historical RatesSPEC,0,1115.1
   % sprintf('rm_ro,Historical RatesSPEC : Historical Rate Surface,Historical Rate Surface,Historical RatesSPEC,365,1161.92456250268    

end

function out = processFx(base, algoCurve, sessionDate, timesteps, stoScenario, debug, numberFormat)
    foreign = algoCurve.currency;
    foreignCurve = [ foreign '_nyc_default_sto' ];
    baseCurve = [ base '_nyc_default_sto' ];
    latestRate = stoScenario.expandedUniverse(algoCurve.name).values{1};
    underlying = [foreign '_fx_underlying'];
    
% Additional algo foreign exchange definition snippet 
    %1
    out = [ ...
        sprintf(['BAS,Foreign ExchangeSPEC,Foreign ExchangeSPEC,Foreign Exchange,%s,%s,%s,%s,%s,%s,,,,,,' numberFormat ',%s,FX_Cash_THEO,FX_Cash_MKT'], underlying, underlying, base, foreign, baseCurve, foreignCurve, latestRate, base) endl() ...
    ];
    %BAS,Foreign ExchangeSPEC,Foreign ExchangeSPEC,Foreign Exchange,{foreign},{foreign},{base},{foreign},{baseCurve},{foreignCurve},,,,,,{latestRate},{base},FX_Cash_THEO
    %BAS,Foreign ExchangeSPEC,Foreign ExchangeSPEC,Foreign Exchange,USD,USD,GBP,USD,GBP_NYC_default_sto,USD_NYC_default_sto,,,,,,0.682528235449092,GBP,FX_Cash_THEO

    %2.1
    out = [ out ...
        sprintf('BAS,Exchange RateSPEC,Exchange RateSPEC,Exchange Rate,FX_%s/%s,FX_%s/%s,0,@spot rate,FALSE,TRUE,0,@Interest Rate Parity,@Linear,FALSE,%s,%s', base, foreign, base, foreign, baseCurve , foreignCurve) endl() ...
    ];    
    %'BAS,Exchange RateSPEC,Exchange RateSPEC,Exchange Rate,FX_{base}/{foreign},FX_{base}/{foregn},0,@spot rate,FALSE,TRUE,0,@Interest Rate Parity,@Linear,FALSE,{baseCurve},{foreignCurve}'
    %'BAS,Exchange RateSPEC,Exchange RateSPEC,Exchange Rate,FX_GBP/USD,FX_GBP/USD,0,@spot rate,FALSE,TRUE,0,@Interest Rate Parity,@Linear,FALSE,GBP_NYC_default_sto,USD_NYC_default_sto'
    %2.2
    out = [ out ...
        sprintf('rm_ro,Exchange RateSPEC : Procedure Parameter,Procedure Parameter,Exchange RateSPEC,%s_fx_underlying', foreign) endl() ...
    ];        
    %rm_ro,Exchange RateSPEC : Procedure Parameter,Procedure Parameter,Exchange RateSPEC,{foreign}
    %rm_ro,Exchange RateSPEC : Procedure Parameter,Procedure Parameter,Exchange RateSPEC,USD

% continue with standard algo sto and det curves definitions
    out = [ out makeAlgoIndexDetAndStoCurves(algoCurve, sessionDate, timesteps, stoScenario, debug, numberFormat) ];    
end


function out = processCurve(risk, sessionDate, timesteps, stoScenario, debug, numberFormat)
    
    [tempUnused, det, sto ] = risk.makeAllNames();
    % sto segment has the values of the last timestep
    out = makeAlgoZeroCurveSpec(sto, stoScenario.expandedUniverse(risk.name), numberFormat);
        
    % det segment is further split by timesteps dates:    
    % and each det_mmddyyyy curve is defined as an Algo zero curve
    for i = 1:length(timesteps)
        timestep = timesteps(i);
        curve = [det '_' date2string(prursg.Util.DateUtil.ReplaceLeapDate(timestep.date))];
        out = [ out sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,,@Linear,%%,simple,actual/365,@sum', det, det) endl() ];
        out = [ out sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', curve) endl() ]; %#ok<AGROW>
        % rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,USD_NYC_default_det_31122009
        % rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,USD_NYC_default_det_31122010
        out = [ out makeAlgoZeroCurveSpec(curve, timestep.expandedUniverse(risk.name), numberFormat) ]; %#ok<AGROW>
    end
end

function out = makeAlgoZeroCurveSpec(curve, dataSeries, numberFormat)
    out = '';
    out = [ out sprintf('BAS,ZeroSPEC,ZeroSPEC,Zero,%s,%s,0,,FALSE,TRUE,0,@None,@Linear,FALSE,AAA,%%,annual,actual/365', curve, curve) endl() ];
    
    terms = dataSeries.axes(1).values;
    values = dataSeries.values{1};
    for i = 1:length(values)        
        term = floor(terms(i) * 365);
        out = [out sprintf(['rm_ro,ZeroSPEC : Generic Zero Surface,Generic Zero Surface,ZeroSPEC,%d,' numberFormat], term, values(i)) endl() ]; %#ok<AGROW>
    end    
    %rm_ro,ZeroSPEC : Generic Zero Surface,Generic Zero Surface,ZeroSPEC,365,2.18658853688758E-02
    %rm_ro,ZeroSPEC : Generic Zero Surface,Generic Zero Surface,ZeroSPEC,730,2.79259212042438E-02
    %rm_ro,ZeroSPEC : Generic Zero Surface,Generic Zero Surface,ZeroSPEC,1095,3.28291852897914E-02
end

function out = processCreditSpread(algoCurve, timesteps, stoScenario, debug, numberFormat)
    % sto having the values of the last timestep
    [tempUnused, det, sto ] = algoCurve.makeAllNames();
    out = makeCreditSpread2DSpec(sto, algoCurve, stoScenario.expandedUniverse, numberFormat);

    % det segment is further split by timesteps dates:    
    % and each det_mmddyyyy curve is defined as an Algo 2D vola curve
    for i = 1:length(timesteps)
        timestep = timesteps(i);
        curve = [det '_' date2string(prursg.Util.DateUtil.ReplaceLeapDate(timestep.date))];
        out = [ out sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', det, det) endl() ]; %#ok<AGROW>
        out = [ out sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', curve) endl() ]; %#ok<AGROW>        
        out = [ out makeCreditSpread2DSpec(curve, algoCurve, timestep.expandedUniverse, numberFormat) ]; %#ok<AGROW>
    end    
end

function out = makeCreditSpread2DSpec(curveName, algoCurve, timestep, numberFormat)
    out = [ sprintf('BAS,Credit Spread CurveSPEC,Credit Spread CurveSPEC,Credit Spread Curve,%s,%s,0,actual/365,annual,%%,0,FALSE,FALSE,FALSE,,@Linear,FALSE,,@Constant', curveName, curveName) endl() ];
    values2d = algoCurve.getDeterministicValue(timestep);
    for i = 1:size(values2d, 2)
        rating = algoCurve.creditRatingAxisValues{i};
        for j = 1:size(values2d, 1)
            term = floor(algoCurve.dataSeries.axes(1).values(j) * 365); % in days
            value = values2d(j, i);
            out = [ out sprintf(['rm_ro,Credit Spread CurveSPEC : Credit Spread Surface,Credit Spread Surface,Credit Spread CurveSPEC,%d,%s,' numberFormat], term, rating, value) endl() ]; %#ok<AGROW>
        end  
    end
end


function out = processVol(risk, timesteps, stoScenario, debug, numberFormat)
    % sto having the values of the last timestep
    [tempUnused, det, sto ] = risk.makeAllNames();
    out = makeAlgoVola2DSpec(sto, stoScenario.expandedUniverse(risk.name), numberFormat);

    % det segment is further split by timesteps dates:    
    % and each det_mmddyyyy curve is defined as an Algo 2D vola curve
    for i = 1:length(timesteps)
        timestep = timesteps(i);
        curve = [det '_' date2string(prursg.Util.DateUtil.ReplaceLeapDate(timestep.date))];
        out = [ out sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', det, det) endl() ]; %#ok<AGROW>
        out = [ out sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', curve) endl() ]; %#ok<AGROW>
        % rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,USD_Equity_CRI_IV_default_det_31122009
        
        out = [ out makeAlgoVola2DSpec(curve, timestep.expandedUniverse(risk.name), numberFormat) ]; %#ok<AGROW>
    end    
end

function out = makeAlgoVola2DSpec(curve, dataSeries, numberFormat)
    out = [ sprintf('BAS,Volatility - Moneyness/TermSPEC,Volatility - Moneyness/TermSPEC,Volatility - Moneyness/Term,%s,%s,0,,TRUE,TRUE,0,S / K,@Constant,@Linear,FALSE,@Linear,FALSE,TRUE,%%,annual,actual/365', curve, curve) endl() ];
    moneyness = dataSeries.axes(1);
    term = dataSeries.axes(2);
    values = dataSeries.values{1};
    for i = 1:numel(term.values)
        for j = 1:numel(moneyness.values)
            m = moneyness.values(j);
            t = floor(term.values(i) * 365);
            v = values(j, i);
            out = [ out sprintf(['rm_ro,Volatility - Moneyness/TermSPEC : Generic Volatility Moneyness Term Surface,Generic Volatility Moneyness Term Surface,Volatility - Moneyness/TermSPEC,%d,%d,' numberFormat], m, t, v) endl() ]; %#ok<AGROW>
        end
    end
end


function out = processSvol(risk, timesteps, stoScenario, debug, numberFormat)
    % sto having the values of the last timestep
    [tempUnused, det, sto ] = risk.makeAllNames();
    out = makeAlgoSvola3DSpec(sto, stoScenario.expandedUniverse(risk.name), numberFormat);

    % det segment is further split by timesteps dates:    
    % and each det_mmddyyyy curve is defined as an Algo 3D svola curve
    for i = 1:length(timesteps)
        timestep = timesteps(i);        
        curve = [det '_' date2string(prursg.Util.DateUtil.ReplaceLeapDate(timestep.date))];
        out = [ out sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,@sum', det, det) endl() ]; %#ok<AGROW>
        out = [ out sprintf('rm_ro,Index CurveSPEC : Procedure Parameter,Procedure Parameter,Index CurveSPEC,%s', curve) endl() ]; %#ok<AGROW>        
        out = [ out makeAlgoSvola3DSpec(curve, timestep.expandedUniverse(risk.name), numberFormat) ]; %#ok<AGROW>
    end    
end

function out = makeAlgoSvola3DSpec(curve, dataSeries, numberFormat)
    out = '';
    moneyness = dataSeries.axes(1);
    for i = 1:numel(moneyness.values)
        m = moneyness.values(i);
        out = [ out sprintf('BAS,Volatility - Moneyness/Term/TermSPEC,Volatility - Moneyness/Term/TermSPEC,Volatility - Moneyness/Term/Term,%s,%s,0,,TRUE,0,%%,annual,actual/365,@term/term 3D', curve, curve) endl() ]; %#ok<AGROW>
        out = [ out sprintf('rm_ro,Volatility - Moneyness/Term/TermSPEC : Function Parameters,Function Parameters,Volatility - Moneyness/Term/TermSPEC,1,%d', m) endl() ]; %#ok<AGROW>
        
        moneynessCurve =  [ curve '_' num2str(m) ];
        out = [ out sprintf('rm_ro,Volatility - Moneyness/Term/TermSPEC : Procedure Parameter,Procedure Parameter,Volatility - Moneyness/Term/TermSPEC,1,%s', moneynessCurve) endl() ]; %#ok<AGROW>
        out = [ out makeMoneynessCurve(moneynessCurve, i, dataSeries, numberFormat) ]; %#ok<AGROW>
    end
end

function out = makeMoneynessCurve(curveName, moneynessIndex, dataSeries, numberFormat)
    out = [ sprintf('BAS,Volatility - Term/TermSPEC,Volatility - Term/TermSPEC,Volatility - Term/Term,%s,%s,0,,TRUE,TRUE,0,@Constant,@Linear,FALSE,@Linear,FALSE,TRUE,%%,annual,actual/365,', curveName, curveName) endl() ];
    term = dataSeries.axes(2);
    tenor = dataSeries.axes(3);
    values = dataSeries.values{1};
    for i = 1:numel(term.values)
        for j = 1:numel(tenor.values)
            t1 = floor(term.values(i) * 365);
            t2 = floor(tenor.values(j) * 365);
            v = values(moneynessIndex, i, j);
            out = [ out sprintf(['rm_ro,Volatility - Term/TermSPEC : Generic Volatility Term Term Surface,Generic Volatility Term Term Surface,Volatility - Term/TermSPEC,%d,%d,' numberFormat], t1, t2, v) endl() ]; %#ok<AGROW>
        end
    end 
end


function out = finishWithFxConversion(base, currencies, debug)
    %3
    out = debugInit(debug, [ endl() '# fx convertor' endl() ]);
    out = [ out 'BAS,FX ConverterSPEC,FX ConverterSPEC,FX Converter,FX_Converter' endl() ];
    
    for i = 1:length(currencies)
        foreign = currencies{i};
        out = [ out ...
            sprintf('rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_%s/%s,%s,%s,%d', base, foreign, foreign, base, i) ... 
            endl() ...
        ]; %#ok<AGROW>
        %rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_{base}/{foreign},{foreign},{base},{i}
        %rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_GBP/USD,USD,GBP,1
        %rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_GBP/EUR,EUR,GBP,2
        %rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_GBP/SGD,SGD,GBP,3
        %rm_ro,FX ConverterSPEC : FXConverter,FXConverter,FX ConverterSPEC,FX_GBP/GBP,GBP,GBP,4
    end
    
    for i = 1:length(currencies)
        foreign = currencies{i};
        sto = [ foreign '_Cash_default_sto' ];
        out = [ out ...
            sprintf('BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,%s,%s,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%%,simple,actual/365,', sto, sto) ...
            endl() ...
            'rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1' ...
            endl() ...
        ]; %#ok<AGROW>
        %BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,USD_Cash_default_sto,USD_Cash_default_sto,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,
        %rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1
        %BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,EUR_Cash_default_sto,EUR_Cash_default_sto,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,
        %rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1
        %BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,SGD_Cash_default_sto,SGD_Cash_default_sto,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,
        %rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1
        %BAS,Index CurveSPEC,Index CurveSPEC,Index Curve,GBP_Cash_default_sto,GBP_Cash_default_sto,0,,0,TRUE,0,@Sliding Axis 1,@Constant,@Linear,%,simple,actual/365,
        %rm_ro,Index CurveSPEC : Generic Index Surface,Generic Index Surface,Index CurveSPEC,0,0,1     
    end
end

function str = date2string(d)
    str = datestr(d, 'ddmmyyyy');
end

function out = debugInit(debug, debugMessage)
    out = '';
    if debug
        out = debugMessage;
    end
end

function out = endl()
    out = 10; % '\n'
end

