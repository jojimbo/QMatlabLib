classdef ScenarioDao
    %Read a Scenario object from <scenario> XML tag
        
    methods (Static)
        
        function s = read(scenarioTag)
            s = prursg.Engine.Scenario();
            s.name = getAttribute(scenarioTag, 'name');      
            if (strcmpi(s.name, '__noriskscr'))
                s.isNoRiskScenario = 1;
            end
            s.scen_step = str2double(getAttribute(scenarioTag, 'scen_step'));            
            sdate = getAttribute(scenarioTag, 'date');
            s.date = prursg.Xml.XmlTool.stringToDate(sdate);
                        
            s.number = str2double(getAttribute(scenarioTag, 'number'));
            % read expanded universe values
            riskTags = scenarioTag.getChildNodes();
            for i = 1:riskTags.getLength()
                tag = riskTags.item(i - 1);
                if strcmp(tag.getTagName(), 'risk')                    
                    name = getAttribute(tag, 'name');
                    s.expandedUniverse(name) = readDataSeriesObject(s.date, tag);
                end
            end            
            assert(numel(keys(s.expandedUniverse)) > 0, 'no <risk> tags found');
        end
        
    end %methods
    
end

%private functions
function str = getAttribute(tag, name)
    str = prursg.Xml.XmlTool.getAttribute(tag, name);
end

function dataSeries = readDataSeriesObject(t, xmlRisk)
    dataSeries = prursg.Engine.DataSeries();
    try 
        [axes value] = prursg.Xml.SerialisedHyperCubeDao.read(xmlRisk);
        % a data series of a single hypercube
        dataSeries.dates = t;
        dataSeries.axes = axes;
        dataSeries.values = { value }; 
    catch e
        fprintf('problem %s with xml tag %s\n', e.message, prursg.Xml.XmlTool.toString(xmlRisk, true));
    end
end

