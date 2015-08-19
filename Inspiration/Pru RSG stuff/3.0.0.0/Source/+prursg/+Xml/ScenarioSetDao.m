classdef ScenarioSetDao
    %Read a Scenario object from <scenario> XML tag
        
    methods (Static)
        
        % read one scenario-set
        function sset = read(scenarioSetTag)
            sset = [];
            if ~isempty(scenarioSetTag) && scenarioSetTag.getChildNodes().getLength() > 0
                sset = prursg.Engine.ScenarioSet();
                attribs = scenarioSetTag.getAttributes();
                sset.name = char(attribs.getNamedItem('name').getValue());
                sset.sess_date = prursg.Xml.XmlTool.readDate(scenarioSetTag, 'sess_date', []);
                %
                scenarioTags = scenarioSetTag.getChildNodes();
                for i = 1:scenarioTags.getLength()
                    scenarioTag = scenarioTags.item(i - 1);
                    if strcmp(scenarioTag.getTagName(), 'scenario')
                        scenario = prursg.Xml.ScenarioDao.read(scenarioTag);
                        if scenario.isNoRiskScenario
                            sset.noRiskScenario = scenario;
                        else
                            sset.addScenario(scenario);
                        end                        
                    end
                end
            end
        end
        
        % specialised for user defined sets
        function uds = readUserDefinedSets(xmlUds)
            uds = [];
            for i = 1:xmlUds.getChildNodes().getLength()
                sset = prursg.Xml.ScenarioSetDao.read(xmlUds.getChildNodes().item(i - 1));
                sset = prursg.Engine.UserDefinedScenarioSet(sset);
                uds = [ uds sset]; %#ok<AGROW>
            end
        end        
        
        % specialised for what-id-sets tag
        function [wiss wiss_base_set_name] = readWhatIfSets(what_if_sets_tag)
            wiss = [];
            for i = 1:what_if_sets_tag.getChildNodes().getLength()
                tag = what_if_sets_tag.getChildNodes().item(i - 1);
                if strcmp(tag.getTagName(), 'scenario_set')
                    sset = prursg.Xml.ScenarioSetDao.read(tag);            
                    shock = prursg.Xml.BaseScenarioShockDao.read( ...
                        prursg.Xml.XmlTool.getNode(tag, 'shock_base_scenario') ...
                    );
                    sset = prursg.Engine.WhatIfScenarioSet(sset, shock);
                    wiss = [ wiss sset]; %#ok<AGROW>
                end
            end
            % common for all wiss
            wiss_base_set_name = prursg.Xml.XmlTool.readString(what_if_sets_tag, 'base_set', '');
        end
        
    end %methods
    
end

