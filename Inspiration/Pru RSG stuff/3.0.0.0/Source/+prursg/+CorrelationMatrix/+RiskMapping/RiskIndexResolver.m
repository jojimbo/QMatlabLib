classdef RiskIndexResolver < handle
    %RISKINDEXRESOLVER 
    % Should be used only on Simulation Phase, when a valid correlation
    % matrix exists
    %  Responsibilities:
    % 1) Return the index of a factor in global risk factor list. 
    % 2) Reorders a list of risks to follow the order in the correlation matrix
    % 3) Retrieves risk factor's start and end columns in correlation/inputs matrix

    properties (Constant)
        START_INPUT_COLUMN = 1;
        END_INPUT_COLUMN = 2;
        RISK_INDEX = 3;
    end
    
    properties (Access = public)
        %resolves risk factors names to their index ranges in correlation matrix
        resolver % Map<risk.name, [start_input_column, end_input_column, riskIndex>
        %
    end
    
    methods        
        function obj = RiskIndexResolver(expandedRiskNames)
            obj.resolver = containers.Map();
            % risk names contains consequtive duplicates of the original
            % risk names:
            %   TST_nyc_factor1">0.06</correl_elem> 
            %   TST_nyc_factor2">0</correl_elem> 
            %   TST_nyc_factor3">0</correl_elem> 
            %   TST_ryc_factor1">0</correl_elem> 
            %   TST_nycvol_factor1">0</correl_elem> 
            % multifactor risk factors will have multiple entries.
            previousRiskName = [];
            riskIndex = 0;
            for i = 1:numel(expandedRiskNames)
                riskName = obj.stripRiskName(expandedRiskNames{i});                                
                if(~isKey(obj.resolver, riskName)) 
                    setData(obj.resolver, previousRiskName, obj.END_INPUT_COLUMN, i - 1);
                    previousRiskName = riskName;
                    riskIndex = riskIndex + 1;
                    obj.resolver(riskName) = [ i, 0, riskIndex ];
                end
                %disp([ num2str(riskIndex) ' ' riskName ]);
                %disp([ riskName ]);
            end
            setData(obj.resolver, previousRiskName, obj.END_INPUT_COLUMN, numel(expandedRiskNames));
        end
                
        function name = stripRiskName(obj, riskName)            
            dashLocations = strfind(riskName, '_');
            name = riskName(1:dashLocations(end) - 1); % strip the _factorX bit
        end
        
        function startAndEndColumns = getStochasticInputRange(obj, riskName)
            if (isKey(obj.resolver, riskName))
                data = obj.resolver(riskName);
                startAndEndColumns = data(obj.START_INPUT_COLUMN) ...
                                   : data(obj.END_INPUT_COLUMN);
            else
                % notice that in reOder if a risk was not in the resolver it
                % would be added and given an index (2:1) which would generate 
                % an empty array to an empty array i.e. startAndEndColumns = data(2:1)
                % Now that reOrder is not called we have to deal with not
                % found here. Note, a risk may not be found because the resolver is
                % built using the names in the correlation matrix, but the
                % names passed to this method (and to reOder) are from the
                % risk entries in the control file. It is valid for there
                % to be risks that do not have an entry in the correlation
                % matrix
                startAndEndColumns = 2:1; % Return empty array
            end
                %else % this is a risk which has no stochastic input return an empty matrix range:
            %    startAndEndColumns = 2:1; % matrix(2:1) is Empty matrix: rows-by-0
            %end
            
        end
        
        function index = getIndex(obj, riskName)
            try 
                data = obj.resolver(riskName);
                index = data(obj.RISK_INDEX);
            catch err
                error('Could not find the index of a risk with name "%s"\n', riskName);
                throw(err);
            end
            
        end
        
        function ordered = reOrder(obj, risks)
            % some of the risks are present in the correlation matrix.
            % some - being a pure function on top of other, are not - put
            % them at the back of the ordering.
            out = cell(1, numel(risks)); %numel(risks) >= numel(keys(resolver))
            backIndex = numel(keys(obj.resolver)) + 1;
            for i = 1:numel(risks)
                if isKey(obj.resolver, risks(i).name)
                    out(obj.getIndex(risks(i).name)) = { risks(i) };
                else
                    out(backIndex) = { risks(i) };
                    obj.resolver(risks(i).name) = [ 2, 1, backIndex ]; % matrix(2:1) is Empty matrix: rows-by-0
                    backIndex = backIndex + 1;
                end
            end
            ordered = []; % copy the cell array to an ordinary array. Lame. there must be a better way?
            for i = 1:numel(out)
                ordered = [ ordered out{i} ]; %#ok<AGROW>
            end
        end
        
        function display(obj)
            names = keys(obj.resolver);
            disp(['Resolver entries: ' num2str(numel(names))]);
            for i = 1:numel(names)
                disp([ num2str(obj.getIndex(names{i})) ' ' names{i} ' ' num2str(obj.getStochasticInputRange(names{i})) ]);
            end
        end
    end    
end

function setData(resolver, riskName, index, value)
    if(~isempty(riskName))
        data = resolver(riskName);
        data(index) = value;        
        resolver(riskName) = data;
    end
end



