%% RiskDrivers
% value class

classdef RiskDrivers

    %% Properties
    % 
    % *_private_*
    % 
    % * |Drivers|       _double_
    % 
    % *_Dependent, SetAccess = private_*
    % 
    % * |DriverNames|   _cell_

    properties(Access = private)
        Drivers % TODO: Convert to dataset
    end


    properties(Dependent, SetAccess = private)
        DriverNames
    end


    %% Methods
    %
    % * |obj = RiskDrivers(indexFile)| _constructor_
    methods

        function val = get.DriverNames(this)
            val = this.Drivers.keys;
        end

    end


    methods(Access = public)

        function obj = RiskDrivers(indexFile)
            %% RiskDrivers _constructor_
            % |obj = RiskDrivers(indexFile)| 
            %
            % Inputs:
            %
            % * |indexFile| _char_

            % Open file for reading
            [fid, errMsg] = fopen(indexFile, 'r');

            if fid < 0
                error('ing:FileNotFound', errMsg);
            end

            % Read the columns of interest, in this case I am only interested in the
            % names of the risk drivers and the current value of that risk, which
            % corresponds to the fifth and seventh columns
            readData = textscan(fid, '%*s %*s %*s %*s %s %*s %s %*[^\n]', 'delimiter', ',');
            fclose(fid);

            % Extract data of interest.  This can be achieved by taking the odd an even
            % elements from each of the columns we have extracted.
            riskDriver  = readData{1}(1:2:end);
            data        = str2doubleq(readData{2}(2:2:end));
            obj.Drivers = containers.Map;

            for i = 1:length(riskDriver)
                % Each entry is appended with '-Index Curve' this code
                % removes it (1:end-12)
                obj.Drivers(riskDriver{i}(1:end-12)) = data(i);
            end

        end


        function val = getRiskValue(obj, riskName)
            %% getRiskValue
            % |val = getRiskValue(obj, riskName)|
            % 
            % Inputs:
            % 
            % * |riskName|  _char_
            % 
            % Outputs:
            % 
            % * |val|       _double_
            val = obj.Drivers(riskName);
        end

    end

end
