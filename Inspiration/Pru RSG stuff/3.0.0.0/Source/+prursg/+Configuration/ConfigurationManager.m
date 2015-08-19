classdef ConfigurationManager
    %CONFIGURATIONMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       AppSettings;
       ConnectionStrings;
       HistoricalDataDaoMap;
       MissingDataTreatmentRuleMap;       
       DefaultDaoName;
    end
     
    methods(Static)
        % Set the name of the config file to read. This is meant to aid
        % testing and is not meant to be used in production. Rather tnan set 
        % a global variable this method persists the filename to a .mat file 
        % which is read by getConfigFileName.
        % Grid testing should use the default app.config
        function setConfigFileName(filename)
            save('app.config.mat', 'filename'); 
 %          fprintf('Setting the application cofiguration file name to (%s)\n',...
 %                   filename);
        end
        
        % Get the name of the config file to read. This is meant to aid
        % testing and is not meant to be used in production. This method
        % reads the filename from a .mat file which is set by setConfigFileName.
        % It is read by the ConfigurationManager when it is
        % constructed. If not set the ConfigurationManager defaults to
        % using 'app.config.
        % Grid testing should use the default app.config
        function filename = getConfigFileName()
            filename = [];
            matfile = 'app.config.mat';
            if exist(matfile, 'file')
                load(matfile, 'filename');
     %           fprintf('Retrieving the application cofiguration file name (%s)\n',...
     %               filename);
            end
        end
    end
    
    methods
        % constructors.                
        function obj = ConfigurationManager(filename)
            
            if nargin < 1
                import prursg.Configuration.*;
                filename = ConfigurationManager.getConfigFileName();
                if isempty(filename)
                    filename = fullfile(pwd(), 'app.config');
                else
                    filename = fullfile(pwd(), filename);
                end
            end
            
%            fprintf('Reading RSG application configuration file (%s)\n',...
%                    filename);
            
            if exist(filename, 'file')                
                try
                    % read xml configuration file.
                    xDoc = xmlread(filename);
                    
                    % read app settings
                    appSettingsNode = xDoc.getElementsByTagName('appSettings');
                    if ~isempty(appSettingsNode)
                        obj.AppSettings = obj.ReadAppSettings(appSettingsNode.item(0));
                    end
                    
                    %read connection strings.
                    connectionStringsNode = xDoc.getElementsByTagName('connectionStrings');
                    if ~isempty(connectionStringsNode)
                        obj.ConnectionStrings = obj.ReadDbSettings(connectionStringsNode.item(0));
                    end      
                    
                    %read historical data daos.
                    historicalDataDaosNode = xDoc.getElementsByTagName('historicalDataDaos');
                    if ~isempty(historicalDataDaosNode)
                        obj.DefaultDaoName = char(historicalDataDaosNode.item(0).getAttribute('default'));
                        obj.HistoricalDataDaoMap = obj.ReadFactoryMapData(historicalDataDaosNode.item(0), 'dao');
                    end      
                    
                    %read missing data treatment rules.
                    missingDataTreatmentRulesNode = xDoc.getElementsByTagName('missingDataTreatmentRules');
                    if ~isempty(historicalDataDaosNode)
                        obj.MissingDataTreatmentRuleMap = obj.ReadFactoryMapData(missingDataTreatmentRulesNode.item(0), 'rule');
                    end  
                    
                catch ex
                    disp('Failed to initialise ConfigurationManager.');
                    rethrow(ex);
                end
            else
                me = MException('ConfigurationManager:ConfigurationManager', ['The configuration file not found. FileName-' filename]);
                throw(me);
            end
        end                
    end
    
    methods(Access=private)
        % read app setting elements from the given node.
        function settings = ReadAppSettings(obj, node)
            settings = containers.Map('KeyType', 'char', 'ValueType', 'char');
            settingNodeList = node.getElementsByTagName('setting');
            if ~isempty(settingNodeList)                
                for i = 0:settingNodeList.getLength() - 1
                    settings(char(settingNodeList.item(i).getAttributes().getNamedItem('key').getNodeValue())) = ...
                        char(settingNodeList.item(i).getAttributes().getNamedItem('value').getNodeValue());
                end                            
            end
        end  
        
        % read app setting elements from the given node.
        function settings = ReadDbSettings(obj, node)
            import prursg.Configuration.*;
            
            settings = containers.Map('KeyType', 'char', 'ValueType', 'any');
            settingNodeList = node.getElementsByTagName('dbSetting');
            if ~isempty(settingNodeList)                
                for i = 0:settingNodeList.getLength() - 1
                    dbSetting = DbSetting();
                    dbSetting.DatabaseName = char(settingNodeList.item(i).getAttributes().getNamedItem('databaseName').getNodeValue());
                    dbSetting.UserName = char(settingNodeList.item(i).getAttributes().getNamedItem('userName').getNodeValue());
                    dbSetting.Password = char(settingNodeList.item(i).getAttributes().getNamedItem('password').getNodeValue());
                    dbSetting.Url = char(settingNodeList.item(i).getAttributes().getNamedItem('url').getNodeValue());
                    settings(char(settingNodeList.item(i).getAttributes().getNamedItem('key').getNodeValue())) = ...
                        dbSetting;
                end                            
            end
        end                
        
                
        % read data required to create a factory class.
        function map = ReadFactoryMapData(obj, node, subNodeName)
            import prursg.Configuration.*;            
            map = containers.Map('KeyType', 'char', 'ValueType', 'any');
            nodeList = node.getElementsByTagName(subNodeName);
            if ~isempty(nodeList)                
                for i = 0:nodeList.getLength() - 1                    
                    item = FactoryItem();
                    item.Name = char(nodeList.item(i).getAttributes().getNamedItem('name').getNodeValue());
                    item.Class = char(nodeList.item(i).getAttributes().getNamedItem('class').getNodeValue());
                    
                    propertyList = nodeList.item(i).getElementsByTagName('property');
                    if ~isempty(propertyList)
                        for j = 1:propertyList.getLength()
                            name = char(propertyList.item( j -1).getAttribute('name'));
                            value = char(propertyList.item( j -1).getTextContent());
                            if ~isempty(name)
                                item.Properties(name) = value;
                            end
                        end
                    end                    
                    map(item.Name) = item;                        
                end                            
            end
        end
        
    end
    
end

