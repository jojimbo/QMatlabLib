classdef rsg_job < prursg.Db.Dto
    %RSG_JOB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rsg_job_id
        job_start
        job_end
        basecurrency
        num_simulations
        xml_model_file
        retain_flag
        persist_until        
    end
    
    methods
        
        function obj = rsg_job(varargin)
            if numel(varargin) == 1
                modelFile = varargin{1};
                obj.basecurrency = modelFile.basecurrency;
                obj.num_simulations = modelFile.num_simulations;
                obj.xml_model_file = prursg.Xml.XmlTool.toString(modelFile.modelFileDOM, true);
                obj.retain_flag = 'Y';
                obj.persist_until = now() + 365 * 10;                
            end
        end
        
        function set.job_start(obj, t)
            obj.job_start = obj.floorToSecond(t);
        end
        
        function set.job_end(obj, t)
            obj.job_end = obj.floorToSecond(t);
        end
        
        function set.persist_until(obj, t)
            obj.persist_until = obj.floorToSecond(t);
        end
               
        function set.xml_model_file(obj, valueOrBlob)
            if ischar(valueOrBlob)
                obj.xml_model_file = valueOrBlob;
            else
                obj.xml_model_file = obj.getString(valueOrBlob);
            end
        end
        
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from %s where rsg_job_id=%d', obj.getTableName(), obj.rsg_job_id) ...
            );
            close(q);
        end
        
        function obj = read(obj, connection)
            sqlSelect = sprintf('select * from %s where rsg_job_id=%d', obj.getTableName(), obj.rsg_job_id);
            obj.selectAndPopulateProperties(connection, sqlSelect);            
        end
        
        function row = getTableRow(obj)
            xmlBytes = unicode2native(obj.xml_model_file);            
            row = { obj.rsg_job_id, obj.job_start, obj.job_end, obj.basecurrency ...
                  , obj.num_simulations, xmlBytes, obj.retain_flag, obj.persist_until };
        end
    end
        
end

