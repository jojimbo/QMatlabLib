classdef SerialisedHyperCubeDao
    %HYPERCUBEDAO read a Nd model parameter or expanded universe risk
    %factor value. HyperCube is serialised into a vector. As the
    %xml serialisation is not always done according to the Algo axis
    %sequence convention, this DAO must be always used to read model
    %parameters or expanded universe values from the XML model file,
    %allthough this is slow!
    
    properties (Constant) % clumsy but substitutes a static property
        useJava = containers.Map();
    end
    
    methods (Static)
        function [axes value] = read(xmlRisk, varargin) 
            % axes - a vector of axis, empty for a 0d object
            % value - a Nd matrix
            import prursg.Xml.*;
            axes = readAxes(xmlRisk);
            if(numel(varargin) > 0)
                valuesTagName = varargin{1};
                vtagName = varargin{2};
            else
                valuesTagName = 'values';
                vtagName = 'v';
            end
            valuesTag = prursg.Xml.XmlTool.getNode(xmlRisk, valuesTagName);
                
            if(numel(axes) == 0) % scalar risk factor
                if isempty(valuesTag.getFirstChild().getFirstChild())
                    value = 0; % in uncalibrated MF, if model parameters are null, default to zero
                else
                    value = str2double(valuesTag.getFirstChild().getFirstChild.getData());
                end
            else % Nd risk factor
                value = readHyperCube(axes, valuesTag);
            end
        end        
    end
end

function cube = readHyperCube(axes, svNode)
    
    % clumsy but substitutes a static property
    useJava = numel(keys(prursg.Xml.SerialisedHyperCubeDao.useJava)) > 0;

    % first pass reads all axis values - to figure out the dimensionality of the cube
    xmlValues = svNode.getChildNodes();
    
    % copy xml structure into matlab arrays to speed up things on second pass
    % minimising str2double calls
    if useJava
        [attributeValues values] = javaReadHyperCube(axes, svNode);
    else
        attributeValues = zeros(xmlValues.getLength(), numel(axes));
        values = zeros(xmlValues.getLength(), 1);    
        for i = 1:xmlValues.getLength();
            [attributeValues(i, :) values(i)] = processAxisValues(axes, xmlValues.item(i - 1), attributeValues(i, :));
        end
    end
    if numel(axes) == 1 % speed up for 1d yield curves
        cube = values;
    else
        cube = prursg.Engine.HyperCube.makeCubeOfZeros(axes);
        coords = zeros(1, numel(axes));
        for i = 1:numel(values)
            for j = 1:numel(axes)
                if iscell(axes(j).values)
                    matValues = cell2mat(axes(j).values);
                else
                    matValues = axes(j).values;
                end
                coords(j) = find(matValues == attributeValues(i, j));                    
            end
            cube = prursg.Engine.HyperCube.setElement(cube, coords, values(i));
        end        
    end
end

function [attribs value] = processAxisValues(axes, xmlv, attribs)    
    for i = 1:numel(axes)
        a = xmlv.getAttribute(axes(i).title);        
        attribs(i) = java.lang.Double.parseDouble(a);
        axes(i).addValue(attribs(i));
    end
    if isempty(xmlv.getFirstChild())
        value = 0; % in uncalibrated MF, if model parameters are null, default to zero
    else
        value = java.lang.Double.parseDouble(xmlv.getFirstChild().getData()); % TODO replace parseDouble with str2double which is slower
    end
end

function [attributeValues values] = javaReadHyperCube(axes, svNode)
    %disp('in java hyper cube');
    axesNames = javaArray('java.lang.String', numel(axes));
    for i = 1:numel(axes)
        axesNames(i) = java.lang.String(axes(i).title);
    end
    %
    out = xml.XmlParser.parseSerialisedCubeValues(axesNames,svNode);    
    
    values = out(2);
    attributeValues = values(:, 1:end -1);
    values = values(:, end);
    axisValues = out(1);
    for i = 1:numel(axes)
        axes(i).values = axisValues(i).getValues()';
    end
        
end

function axes = readAxes(xmlRisk)
    import prursg.Xml.*;
    axes = [];
    axesNode = XmlTool.getNode(xmlRisk, 'axes');
    if(~isempty(axesNode) && axesNode.getChildNodes().getLength() > 0)
        xmlAxes = axesNode.getChildNodes();
        nAxes = xmlAxes.getLength();
        for i = 1:nAxes
            axis = readAxis(i, xmlAxes.item(i - 1));
            axes = [axes axis]; %#ok<AGROW>
        end
    end
end

function axis = readAxis(i, axisNode)
    % the access values are encoded as attribute values with the serialised
    % hyper cube grid
    axis = prursg.Engine.Axis();
    axis.title = char(axisNode.getAttribute('name'));
    if(isempty(axis.title))
        axis.title = num2str(i);
    end    
end
