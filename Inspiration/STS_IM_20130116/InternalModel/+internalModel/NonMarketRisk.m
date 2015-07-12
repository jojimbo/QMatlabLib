%% NonMarketRisk class definition
% subclass of internalModel.Instrument

classdef NonMarketRisk < internalModel.Instrument

    %% Properties
    % 
    % * |BaseEntity|    _char_
    % * |ECParameters|  _double_
    % * |Granularity|   _char_
    % * |ProductFamily| _char_
    % * |RiskType|      _char_

    properties(GetAccess = public, SetAccess = protected)

        BaseEntity
        ECParameters
        Granularity
        ProductFamily
        RiskType        

    end


    %% Methods
    % 
    % * |obj        = NonMarketRisk(name, currency, ecParameters)| _constructor_
    % * |val        = value(this, scenarioCollection)|
    % * |ECVector   = calculateECVector(this, confidenceLvl)|
    % 
    % *_Private_*
    % 
    % * |obj        = extractClassificationsFromName(obj, name)|

    methods
        function this = NonMarketRisk(name, currency, ecParameters)
            %% NonMarketRisk constructor
            % |obj = NonMarketRisk(name, currency, ecParameters)|
            % Creation of a NonMarketRisk object
            % 
            % Input:
            % 
            % * |name|          _char_
            % * |currency|      _char_
            % * |ecParameters|  _double_

            this.Name         = name;
            this.Currency     = currency;
            this.MarketRisk   = false;
            this.ECParameters = ecParameters;
            this              = this.extractClassificationsFromName(name);

        end


        function val = value(obj, scenarioCollection) %#ok<STOUT,MANU,INUSD>
            %% value
            % *NOT IMPLEMENTED*
            % 
            % |val = value(obj, scenarioCollection)|
            % 
            % Valuation of NonMarketRisk object
            % 
            % Input:
            % 
            % * |scenarioCollection|    _scenarioCollection_
            % 
            % Output:
            % 
            % * |val|   _double_

            error('Not implemented');
        end


        function ECVector = calculateECVector(this, confidenceLvl)
            %% calculateECVector
            % |ECVector = calculateECVector(this)|
            % 
            % Calculate EC vector for this NonMarketRisk object
            % 
            % Input: 
            % 
            % * |confidenceLvl| _double_
            % 
            % Output:
            % 
            % * |ECvector|      _double_
            % 
            % Formula is given by:
            % $EC_{vector} = a + bx + cx^2 + dx^3 + fe^{gx}$
            % 
            % in which:
            % $a, b, c, d, f$ and $g$ are |ECParameters|
            % 
            % $x$ is |norminv(confidenceLvl)|

            % Collect data
            ecPar = this.ECParameters;

            % Enforce 'confidenceLvl' boundaries
            confidenceLvl = min(confidenceLvl, confidenceLvl - 2*eps);
            confidenceLvl = max(confidenceLvl, 0 + 2*eps);
            x = norminv(confidenceLvl);

            % Perform EC Calculation
            ECVector = ecPar(1) + ecPar(2)*x + ecPar(3)*x.^2 + ...
                        ecPar(4)*x.^3 + ecPar(5).*exp(ecPar(6)*x);
        end

    end % #methods


    methods (Access = private)

        function obj = extractClassificationsFromName(obj, name)
            %% extractClassificationsFromName _private_
            % |obj = extractClassificationsFromName(obj, name)|
            % 
            % Extract classifications from a character array and set the
            % object's properties according to this
            % 
            % Input: 
            % 
            % * |name|  _char_

            % Find all underscores
            udsc = strfind(name, '_');

            if numel(udsc)<4
                % Can't extract clasifications
                warning('NonMarketRisk:NoClass','No classification for %s', name);
                return
            end

            obj.BaseEntity    = name(1:udsc(1)-1);
            obj.Granularity   = name(udsc(end-1)+1:udsc(end)-1);
            obj.RiskType      = name(udsc(end-2)+1:udsc(end-1)-1);
            obj.ProductFamily = name(udsc(1)+1:udsc(end-2)-1);

        end

    end %# Methods Private

end
