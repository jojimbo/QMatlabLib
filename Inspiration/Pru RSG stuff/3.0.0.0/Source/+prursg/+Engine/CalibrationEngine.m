classdef CalibrationEngine < prursg.Engine.Engine
    % core engine that performs calibration of risk factors to chosen
    % models, which should simply loop over all risk factors and invoke the
    % underlying calibrate method

    
    methods
        function obj = CalibrationEngine()
            % CalibrationEngine - Constructor
            %   obj = CalibrationEngine()
            obj = obj@prursg.Engine.Engine();
        end
        
        function calibrate(obj)
            % CalibrationEngine.calibrate - calibrate models
            
            try
                factory = prursg.HistoricalDAO.HistoricalDataDaoFactory();
                dao = factory.Create();                    
                    
                for i=1:numel(obj.risks)
                    disp(['CalibrationEngine - Msg: Calibrating risk ' obj.risks(i).name ' with model ' obj.risks(i).model.name]);
                    calibSource = obj.risks(i).model.calibrationSource;
                    calibTarget = obj.risks(i).model.calibrationTargets;
                    % retrive calibration source
                    dataSeries = {};
                    if ~isempty(calibSource)                        
                        for j = 1:length(calibSource.ids)
                            ds = dao.PopulateData(calibSource.ids{j}, calibSource.from{j}, calibSource.to{j}, [], calibSource.status{j}, calibSource.purpose{j}, calibSource.frequency{j}, calibSource.dateOfMonth{j}, calibSource.holidayCalendar{j}, calibSource.missingDataTreatmentRule{j});
                            if ~isempty(ds)
                                dataSeries{end + 1} = ds;
                            end                        
                        end                    
                    end
                    % retrive calibration targets
                    [calibParamNames calibParamTargets] = obj.populateCalibParams(calibTarget);

                    try
                        obj.risks(i).model.calibrate(dataSeries, calibParamNames, calibParamTargets);
                    catch e
                        fprintf('CalibrationEngine:Risk %s model failed to calibrate,error is %s\n',...
                        obj.risks(i).name, e.message);
                    end
                end
            catch e
                fprintf('CalibrationEngine:Risk %s model failed to calibrate,error is %s\n',...
                    obj.risks(i).name, e.message);
            end
        end
        function dataObj = populateDataObj(obj,calibSource, DAO)
            if ~isempty(calibSource)
                for j = 1:length(calibSource.ids)
                    dataObj{j} = DAO.populateData(calibSource.ids{j},datestr(calibSource.from,24),datestr(calibSource.to,24));
                end
            else
                dataObj = [];
            end
        end
        function [calibParamNames calibParamTargets] = populateCalibParams(obj,calibTarget)
            if ~isempty(calibTarget)
                for j = 1:length(calibTarget)
                    calibParamNames{j} = calibTarget(j).percentile;
                    calibParamTargets{j} = calibTarget(j).value;
                end
            else
                calibParamNames = [];
                calibParamTargets = [];
            end
        end
    end
end

                    