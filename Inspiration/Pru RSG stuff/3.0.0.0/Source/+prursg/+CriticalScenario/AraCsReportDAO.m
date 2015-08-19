classdef AraCsReportDAO < prursg.CriticalScenario.IAraReportDAO
    % Represents a DAO class loading the critical scenario id report.
        
    properties
        FileName = [];
    end
    
    methods
        
        % constructor.
        function dao = AraCsReportDAO(fileName)
            dao.FileName = fileName;
        end
        
        % load ARA report.
        % data = n * 3 cell containing node names, arrays of critical
        % scenario ids and weightings.
        function data = Load(obj)
            data = {};
            
            disp([datestr(now) ' Loading ARA report....']);
            
            if isempty(obj.FileName)
                throw(MException('AraCsReportDAO:Load', 'The FileName property is not set.'));
            end
            
            % check the file path.
            path = '';
            [dirPath fileName fileExt] = fileparts(obj.FileName);
            if isempty(dirPath)
                path = fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath() ,'ARAReports', [fileName fileExt]);
            else
                path = obj.FileName;
            end

            if ~exist(path, 'file')
                msg = [path ' does not exist.'];
                throw(MException('AraCsReportDAO:Load', msg));
            end

            % read all data.
            fid = fopen(path);
            header = fgetl(fid);
            header = textscan(header, '%s', 'delimiter', ',');
            nCols = size(header{1,1}, 1);
            contents = textscan(fid, repmat('%s', 1, nCols), 'delimiter', ',');
            nRows = size(contents{1, 1}, 1);

            rearranged = cell(nRows, nCols);

            weightings = zeros(1, nCols - 1);
            % retrieve weightings.
            for i = 2:nCols
               columnName = header{1, 1}{i, 1};
               columnName = strtrim(columnName);
               indexes = strfind(columnName, ' ');
               if ~isempty(indexes) && indexes(1) > 0
                    length = indexes(1) - 1;
                    columnName = columnName(1:length);
                    weightings(1, i - 1) = str2num(strrep(strrep(strrep(columnName, 'Scen_', ''), 'minus', '-'), 'plus', ''));
               end

            end

            % re-arrange the data.
            for i = 1:nCols
                rearranged(:, i) = contents{1, i};
            end

            data = cell(nRows, 3); % column1 - node name, column2 - vector of scenario ids, column3 - weighthings.                      
            for i = 1:nRows
                data(i, 1) = {obj.GetNodeName(rearranged{i, 1})};                
                cellValues = cellfun(@(x)((strrep(x, 'SCEN_', ''))), rearranged(i, 2:end), 'UniformOutput', 0);
                matValues = zeros(1, numel(cellValues));
                for j = 1 : numel(cellValues)
                    numValue = str2num(cellValues{j});
                    if ~isempty(numValue)
                        matValues(j) = numValue;
                    end                    
                end
                data(i, 2) = {matValues};
                data(i, 3) = {weightings};
            end

            fclose(fid);
            
            disp([datestr(now) ' ARA report loading completed.']);            
        end
                    
    end
    
    methods(Access=private)
        
        % retrieve the node name from the given full name.
        function nodeName = GetNodeName(obj, fullName)
            nodeName = fullName;
            
            if ~isempty(fullName)
                indexes = strfind(fullName, '>>');        
                if ~isempty(indexes) 
                    n =numel(indexes);
                    if n > 0 && n < size(fullName, 2)
                        nodeName = fullName(indexes(n) + 2 : end);
                        nodeName = strtrim(nodeName);

                        indexes = strfind(nodeName, ':');
                        if ~isempty(indexes)
                            n = numel(indexes);
                            if n > 0 && n < size(nodeName, 2)
                                nodeName = strtrim(nodeName(indexes(n) + 1:end));
                            end
                        end
                    end
                end
            end
        end        
    end
end

