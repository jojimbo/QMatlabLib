function settings = ReadAppSettings(node)
    settings = containers.Map('KeyType', 'char', 'ValueType', 'char');
    settingNodeList = node.getElementsByTagName('setting');
    if ~isempty(settingNodeList)
        for i = 0:settingNodeList.getLength() - 1
            settings(char(settingNodeList.item(i).getAttributes().getNamedItem('key').getNodeValue())) = ...
                char(settingNodeList.item(i).getAttributes().getNamedItem('value').getNodeValue());
        end
    end
end
