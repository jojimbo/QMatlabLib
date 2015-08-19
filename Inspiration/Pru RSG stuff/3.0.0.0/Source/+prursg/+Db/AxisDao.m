classdef AxisDao
    
    
    methods (Static)
        function insert(dao, axes, scenarioSetId, riskFactorId)
            for i = 1:numel(axes)
                insertAxis(dao, axes(i), i, scenarioSetId, riskFactorId);
            end                        
        end
        
        function axes = read(dao, scenarioSetId, riskFactorId)
            axes = [];
            axesList = selectAxesNames(dao, scenarioSetId, riskFactorId);
            for i = 1:size(axesList, 1)
                axes = [ axes readAxis(dao.connection, axesList{i, 1}, axesList{i, 2}) ]; %#ok<AGROW>
            end
        end
        
        function riskNameToAxesResolver = makeRiskNameToAxesResolver(dao, scenarioSetId)
            riskNameToAxesResolver = prursg.Engine.DefaultValueMap();
            sql = [ 'select r.risk_factor_name, a.axis_risk_factor_id from axis a, risk_factor r ' ...
                    'where r.risk_factor_id = a.axis_risk_factor_id and a.axis_scenario_set_id = %d' ];            
            data = dao.select(sprintf(sql, scenarioSetId));
            for i = 1:size(data, 1)
                riskNameToAxesResolver(data{i, 1}) = data{i, 2};
            end
            % replace riskIds with their axes vectors
            k = keys(riskNameToAxesResolver);
            for i = 1:numel(k)
                riskNameToAxesResolver(k{i}) = prursg.Db.AxisDao.read(...
                    dao, scenarioSetId, riskNameToAxesResolver(k{i}) ...
                );
            end            
        end
        
    end
         
end

function axesList = selectAxesNames(dao, axis_scenario_set_id, axis_risk_factor_id)    
    sql = sprintf('select axis_id, axis_name from axis where axis_scenario_set_id = %d and axis_risk_factor_id = %d order by axis_number', ...
                  axis_scenario_set_id,axis_risk_factor_id);
    axesList = dao.select(sql);
end

function axis = readAxis(connection, id, name)
    axis = prursg.Engine.Axis();
    axis.title = name;
    
    sqlSelect = sprintf('select av_value from axis_value where av_axis_id = %d order by av_number', id);
    %
    q = exec(connection, sqlSelect);
    q = fetch(q);
    dbData = q.Data;
    axis.values = cell2mat(dbData)';
    close(q);
end

function insertAxis(dao, axis, axisNumber, scenarioSetId, riskFactorId)    
    a = prursg.Db.axis();
    a.axis_id = dao.getNextId(a);
    a.axis_scenario_set_id = scenarioSetId;
    a.axis_risk_factor_id = riskFactorId;
    a.axis_number = axisNumber;
    a.axis_name = axis.title;
    dao.insert(a);    
    %
    v = prursg.Db.axis_value();    
    nRows = numel(axis.values);
    data = cell(nRows, 3);
    for i = 1:nRows
        data{i, 1} = a.axis_id;
        data{i, 2} = i;
        data{i, 3} = axis.values(i);
    end
    dao.fastinsert(v.getTableName(), v.getTableColumnNames(), data);    
    
end
