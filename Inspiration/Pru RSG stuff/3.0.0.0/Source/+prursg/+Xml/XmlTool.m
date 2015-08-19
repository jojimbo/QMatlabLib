classdef XmlTool
    %XMLTOOL simple xml text conversion routines    
    
    properties
    end
    
    methods(Static)
        
        % search a xml subtree for a node with name = nodeName
        % and convert its text value contents to a to a matlab double 
        % if the node contents are empty returns defaultValue
        function dbl = readDouble(xml, nodeName, defaultValue)
            parser = @(str) str2double(str);
            dbl = readObject(xml, nodeName, parser, defaultValue);
        end

        function vector = readDoubleVector(nodeList)
            vector = zeros(nodeList.getLength(), 1);
            for i = 1:numel(vector)
                node = nodeList.item(i - 1);
                vector(i) = str2double(node.getFirstChild().getData());
            end
        end
        
        % search in xml subtree for a node with name = nodeName
        % and convert its text value contents to a matlab string
        function str = readString(xml, nodeName, defaultValue)
            parser = @(str) str;
            str = readObject(xml, nodeName, parser, defaultValue);
        end
        
        % search in xml subtree for a node with name = nodeName
        % and convert its text value contents to a matlab dateenum
        function t = readDate(xml, nodeName, defaultValue)
            parser = @(str) prursg.Xml.XmlTool.stringToDate(str);
            t = readObject(xml, nodeName, parser, defaultValue);
        end
        
        function str = getAttribute(tag, attributeName)
            str = char(tag.getAttribute(attributeName));
        end
        
        % search in xml subtree for a node with name = nodeName
        % and return it 
        function xmlNode = getNode(xml, nodeName)
            xmlNode = xml.getElementsByTagName(nodeName).item(0);
        end
        
        % xml modification routines        
        % changes the value of the TextNode attached to a xml element with
        % name nodeName. The xml element is part of the xml tree - xml.
        % It may accept an optional parameter to specify the number format
        % for numeric values.
        function setNodeTextValue(xml, nodeName, value, varargin)
            
            numberFormat = 20;
            if ~isempty(varargin)
                numberFormat = varargin{1};
            end            
                        
            if isa(value, 'double')
                value = num2str(value, numberFormat);
            end
            
            % if the tag is empty: <currency/> - there will be no xml
            % TextNode attached to it. Create one first.
            tag = xml.getElementsByTagName(nodeName).item(0);
            textNode = tag.getFirstChild();
            if isempty(textNode)
                textNode = tag.getOwnerDocument().createTextNode('not_important');
                tag.appendChild(textNode);
            end
            textNode.setNodeValue(value);    
        end
        
        % write an xml document to a string removing unnescessacy carriage
        % returns etc that matlabs xmlwrite will create. 
        % see:        
        function str = toString(domOrElement, stripVersionHeader)           
            if isempty(strfind(class(domOrElement), 'Document'))
                dom = domOrElement.getOwnerDocument();
                node = domOrElement;
            else
                dom = domOrElement;
                node = dom.getDocumentElement();
            end
            %
            %str = strrep(char(docNode.saveXML(docNodeRoot)), 'encoding="UTF-16"', 'encoding="UTF-8"');
            %  str = strrep(str, '<?xml version="1.0" encoding="UTF-16"?>', '');
            % length('<?xml version="1.0" encoding="UTF-16"?>')
            str = char(dom.saveXML(node));            
            if stripVersionHeader
                pos = strfind(str, '?>');
                str = str(pos(1) + 3:end); % remove <?xml version="1.0" encoding="UTF-16"?>CR fragment
            end
        end
                
        function node = removeChildNodes(node)
            while node.hasChildNodes()
                node.removeChild(node.getFirstChild());
            end            
        end
        
        % date functions
        function out = stringToDate(dateString)
            out = datenum(dateString, 'dd/mm/yyyy');
        end
        
        function out = dateToString(datenumber)
            out = datestr(datenumber, 'dd/mm/yyyy');
        end 
        
        % Extract the named element from the DOM. It is an error if more
        % than one element named node_name exists
        function item = getAndExpectOneElementItemByName(xml, node_name)
            xmlNode = xml.getElementsByTagName(node_name);
            if xmlNode.getLength() ~= 1
               fprintf('Error: Expectings one "%s" element but found %d instances instead\n',...
                   node_name, xmlNode.getLength());
               throw(MException('XmlTool:getAndExpectOneElement:MalformedInput',...
                   ['Could not find ' node_name]));
            end 
            
            % item(item(0) is safe as we know there is only one in xmlNodes
            item = xmlNode.item(0);
        end
    end %static
    
end

%private function's declaration

%return the textNode content of an xml node with name nodeName
function xmlTextNode = getTextNode(xml, nodeName) 
    xmlTextNode = xml.getElementsByTagName(nodeName).item(0).getFirstChild();
end

function object = readObject(xml, nodeName, parser, defaultValue)
    object = defaultValue;
    xmlElements = xml.getElementsByTagName(nodeName);    
    if xmlElements.getLength() > 0    
        xmlTextNode = xmlElements.item(0).getFirstChild();
        if(~isempty(xmlTextNode))
            object = parser(char(xmlTextNode.getData()));%convert the java.lang.String
        end
    end
end
