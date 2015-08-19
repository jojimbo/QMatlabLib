classdef BaseScenarioShockDao
    %Read a Scenario object from <scenario> XML tag
        
    methods (Static)
        
        function s = read(shockTag)
            s = prursg.Engine.BaseScenarioShock();
            attribs = shockTag.getAttributes();
            s.name = attribs.getNamedItem('name').getValue();
            sdate = char(attribs.getNamedItem('date').getValue());
            s.date = prursg.Xml.XmlTool.stringToDate(sdate);
            
            % read shifts and stretches
            riskTags = shockTag.getChildNodes();
            for i = 1:riskTags.getLength()
                tag = riskTags.item(i - 1);
                if strcmp(tag.getTagName(), 'risk')
                    name = char(tag.getAttributes().getNamedItem('name').getValue());
                    
                    if tag.getElementsByTagName('shift_coefficients').getLength() >0
                        s.shiftCoefficients(name) = readDataSeriesObject(s.date, tag, 'shift_coefficients', 'v');
                    else
                        error(['Missing <shift_coefficients> tag for risk ', name]);
                    end
                    if tag.getElementsByTagName('stretch_coefficients').getLength() >0
                        s.stretchCoefficients(name) = readDataSeriesObject(s.date, tag, 'stretch_coefficients', 'm');
                    else
                        error(['Missing <stretch_coefficients> tag for risk ', name]);
                    end
                    
                    
                    if tag.getElementsByTagName('manual_shift_coefficients').getLength() >0
                        s.manualShiftCoefficients(name) = readDataSeriesObject(s.date, tag, 'manual_shift_coefficients', 'v');
                    else
                        s.manualShiftCoefficients(name) = []; % This coefficients are optional
                    end
                    
                    if tag.getElementsByTagName('floor_coefficients').getLength() >0
                        s.floorCoefficients(name) = readDataSeriesObject(s.date, tag, 'floor_coefficients', 'v');
                    else
                        s.floorCoefficients(name) = []; % This coefficients are optional
                    end
                    
                    s.multishock(name) = sniffMultishock(prursg.Xml.XmlTool.getNode(tag, 'stretch_coefficients'));
                end
            end            
            assert(numel(keys(s.multishock)) > 0, 'no <risk> tags found');
        end
        
    end %methods
    
end

function yesNo = sniffMultishock(stretchCoefficients)
    xmlv = prursg.Xml.XmlTool.getNode(stretchCoefficients, 'm');
    mshock = prursg.Xml.XmlTool.getAttribute(xmlv, 'multshock');
    yesNo = strcmp('Y', mshock);
end

%private functions
function dataSeries = readDataSeriesObject(t, xmlRisk, valuesTagName, vtagName)    
    [axes value] = prursg.Xml.SerialisedHyperCubeDao.read(xmlRisk, valuesTagName, vtagName);
    % a data series of a single hypercube
    dataSeries = prursg.Engine.DataSeries();
    dataSeries.dates = t;
    dataSeries.axes = axes;
    dataSeries.values = { value }; 
end

