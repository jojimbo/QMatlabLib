function TestRiskIndexResolver()
%TESTCORRELATIONINDEXRESOLVER tests CorrelationIndexResolver
    clear; clc;
    
    dom = xmlread(fullfile('+prursg', '+Test', '+Xml', 'correlation-matrix.xml'));
    firstRow = dom.getFirstChild().getFirstChild();
    rowElements = firstRow.getChildNodes();
    nElements = rowElements.getLength();
    riskNames = cell(1, nElements);
    for i = 1:nElements
        element = rowElements.item(i - 1);
        riskNames{i} = char(element.getAttribute('name'));
    end
    %
    resolver = prursg.Engine.RiskIndexResolver(riskNames);
    results = { ...
            'TST_nyc', 1:3, 1 ; ...
            'TST_ryc', 4:4, 2 ; ...
            'TST_fx', 10:10, 8;...
            'TST_creditcorporate_b', 21:21, 19;...
            'TST_creditcounterparty_type1_aaa', 22:22, 20; ...
    };
    %
    for i = 1:size(results, 1)        
        assert(isequal(resolver.getStochasticInputRange(results{i, 1}), results{i, 2}));
        assert(resolver.getIndex(results{i, 1}) == results{i, 3});
    end    
    %
    testRiskReordering(resolver, riskNames);
    
    testEmptyResolver();
end

function testRiskReordering(resolver, longRiskNames)
    uniques = {};
    for i = 1:numel(longRiskNames);
        riskName = resolver.stripRiskName(longRiskNames{i});        
        if(~ismember(riskName, uniques))
            uniques = [ uniques riskName ]; %#ok<AGROW>
        end        
    end
    
    % randomly reorder risks
    shuffledRiskNames = uniques(randperm(numel(uniques)));
    risks = makeRisks(shuffledRiskNames);
    
    orderedRisks = resolver.reOrder(risks);
    assert(numel(orderedRisks) == numel(uniques));
    for i = 1:numel(orderedRisks)
        assert(strcmp(orderedRisks(i).name, uniques{i}));
    end
    
    
end

function risks = makeRisks(names)
    risks = [];
    for i = 1:numel(names)
        risks = [ risks, prursg.Engine.Risk(names{i}, []) ]; %#ok<AGROW>
    end
end

function testEmptyResolver()
    prursg.Engine.RiskIndexResolver({});
end