classdef CalibrationSource < handle
    %CALIBRATIONSOURCE definition of a calibration to historic dataseries    
    properties
        ids = {} % a cell array of market elements' identifiers (ftse, dax etc.)
        from = {} % a dateenum - start of historical prices range
        to = {}   % a dateenum - end of historical prices range
        frequency = {}
        dateOfMonth = {}
        holidayCalendar = {}
        missingDataTreatmentRule = {}
        status = {}
        purpose = {}
        
    end
        
    methods    
        function result = fromXml(obj, xmlRiskCalibrationSet)
            % returns true on succesful parsing
            import prursg.Xml.*;
            xmlCalibSources = XmlTool.getNode(xmlRiskCalibrationSet, 'calibration_sources');
            if(~isempty(xmlCalibSources))
                xmlCalibSources = xmlCalibSources.getChildNodes();
                for i = 1:xmlCalibSources.getLength()
                    id = char(xmlCalibSources.item(i - 1).getTextContent());
                    if ~isempty(id)
                        obj.ids{end+1} = id;
                        obj.from{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('from'));
                        obj.to{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('to'));
                        obj.frequency{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('frequency'));
                        obj.dateOfMonth{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('dateOfMonth'));
                        obj.holidayCalendar{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('holidayCalendar'));
                        obj.missingDataTreatmentRule{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('missingDataTreatmentRule'));
                        status = str2num(char(xmlCalibSources.item(i - 1).getAttribute('status')));
                        if isempty(status)
                            status = 0;
                        end
                        obj.status{end + 1} = status;
                        obj.purpose{end + 1} = char(xmlCalibSources.item(i - 1).getAttribute('purpose'));
                    end                    
                end                
            end            
            result = ~isempty(obj.ids) && ~isempty(obj.from) && ~isempty(obj.to);
        end
    end
end
