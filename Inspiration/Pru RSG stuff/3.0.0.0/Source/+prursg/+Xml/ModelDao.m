classdef ModelDao
    %MODELDAO serialie/deserialise a prursg.Model to/from XML stream
    % Relies on the fact that all model properties are public and their
    % names correspond to xml tag names
        
    methods (Static)        
        function fromXml(model, xmlRiskTag)
            import prursg.Xml.*;
            xmlRiskCalibrationSet = XmlTool.getNode(xmlRiskTag, 'risk_calibration_set');
            readProperties(model, XmlTool.getNode(xmlRiskCalibrationSet, 'model_params'));
            readCalibrationSources(model, xmlRiskCalibrationSet);
            readCalibrationTargets(model, XmlTool.getNode(xmlRiskCalibrationSet, 'calibration_targets'));
            readModelDependencies(model, XmlTool.getNode(xmlRiskTag, 'model_precedents'));
        end
                
        function toXml(model, modelParamsTag)
            % model properties are to be serialised under 'model_params'
            import prursg.Xml.*;
            meta = metaclass(model);
            props = meta.Properties;
            for i = 1:length(props)
                p = props{i};
                if strcmp(p.SetAccess, 'public')
                    mergeProperty(model, modelParamsTag, p.Name);                    
                end                
            end            
        end
        
        % bark if not all props of a model are populated by the xml stream
        function checkPropertiesArePopulated(model)
            meta = metaclass(model);    
            for i = 1:length(meta.Properties)
                p = meta.Properties{i};
                if strcmp(p.SetAccess, 'public')
                    value = eval(['model.', p.Name, ';']);
                    if isempty(value)
                        error(['property ', model.getName(), '.', p.Name, ' was not found in xml stream']);
                    end
                end
            end
        end
        
    end % static methods
end % classdef

% private functions declaration

function readCalibrationSources(model, xmlRiskCalibrationSet)
    source = prursg.Engine.CalibrationSource();
    if(source.fromXml(xmlRiskCalibrationSet))
        model.calibrationSource = source;
    end
end
    
function readCalibrationTargets(model, xmlCalibTargets)    
    targets = prursg.Engine.CalibrationTarget.fromXml(xmlCalibTargets);    
    if(~isempty(targets))
        model.calibrationTargets = targets;
    end    
end

function readProperties(obj, xmlProps)
    meta = metaclass(obj);
    props = meta.Properties;
    for i = 1:length(props)
        p = props{i};
        % bypass properties that are to be set outside
        if(strcmp(p.Name, 'calibrationTargets') || strcmp(p.Name, 'calibrationSource'))
            continue;
        end
        if strcmp(p.SetAccess, 'public') && ~(p.Constant)
            readProperty(obj, p, xmlProps);
        end
    end
end

function propertyXmlTagWasFound = readProperty(obj, property, xml)
    import prursg.Xml.*;
    
    xmlProperties = xml.getElementsByTagName(property.Name);
    % more than one tag with this name is an error
    if xmlProperties.getLength() > 1
        error(['more than one xml tag found for property: ', property.Name]); 
    end    
    %
    propertyXmlTagWasFound = (xmlProperties.getLength() == 1);
    if propertyXmlTagWasFound
        xmlProp = xmlProperties.item(0);
        [axes value] = prursg.Xml.SerialisedHyperCubeDao.read(xmlProp);
        eval(['obj.' property.Name '= value;']); % is there a better way to do the assignment
    end
end
 
function readModelDependencies(model, xmlModelDependents)
    precedentsTags = xmlModelDependents.getChildNodes();
    nChild = precedentsTags.getLength();
    for i = 1:nChild
        precedent = precedentsTags.item(i - 1);
        formulaParameter = char(precedent.getTagName());
        %
        txtNode = precedent.getFirstChild();
        if ~isempty(txtNode)  % account for an empty  <r/> tag. Yes it happens! 
            precedentRiskFactorName = char(precedent.getFirstChild().getData());
            model.addDependency(formulaParameter, precedentRiskFactorName);
        end
    end
end

function mergeProperty(model, modelParamsTag, propertyName) 
    import prursg.Xml.*;    
    propertyValue = eval(['model.', propertyName]);
    %
    dataSeries = makeDataSeriesObject(propertyValue);
    propertyTag = XmlTool.getNode(modelParamsTag, propertyName);
    if ~isempty(propertyTag) % not all model properties are found in the xml
        mergeDataSeries(propertyTag, dataSeries);
    end
end


function mergeDataSeries(propertyTag, dataSeries)
    prursg.Xml.XmlTool.removeChildNodes(propertyTag);
    propertyTag.appendChild( ...
        makePropertyAxes(propertyTag.getOwnerDocument(), dataSeries.axes) ...
    );
    propertyTag.appendChild( ...
        makePropertyHyperCube(propertyTag.getOwnerDocument(), dataSeries) ...
    );
end

function axesTag = makePropertyAxes(dom, axes)
    axesTag = dom.createElement('axes');
    for i = 1:numel(axes)
        axis = axes(i);
        xmlAxis = dom.createElement('axis');
        xmlAxis.setAttribute('name', axis.title);
        axesTag.appendChild(xmlAxis);
    end
end

function valuesTag = makePropertyHyperCube(dom, dataSeries)
    valuesTag = dom.createElement('values');
    flattenByElement(valuesTag, dataSeries.values{1}, dataSeries.axes, 1, []);
end

function flattenByElement(valuesTag, v, axes, dim, coords)
    for i = 1:size(v, dim) % exaust current dimension
        if dim == ndims(v) % last dimension reached -> create a <v> tag
            vTag = valuesTag.getOwnerDocument().createElement('v');
            addAxesAttributes(vTag, axes, [ coords i]);
            textNode = valuesTag.getOwnerDocument().createTextNode('not_important'); 
            value = prursg.Xml.FormatModelValue(prursg.Engine.HyperCube.getElement(v, [coords i]));
            textNode.setNodeValue(value);
            vTag.appendChild(textNode);
            valuesTag.appendChild(vTag);
        else
            flattenByElement(valuesTag, v, axes, dim + 1, [coords i]);
        end        
    end
end

function addAxesAttributes(vTag, axes, coordinates)
    for i = 1:numel(axes)
        value = prursg.Xml.FormatModelValue(axes(i).values(coordinates(i)));
        vTag.setAttribute(axes(i).title, value);
    end
end

function dseries = makeDataSeriesObject(propertyValue)
    nAxis = prursg.Engine.HyperCube.getNumberOfAxis(propertyValue);    
    axes = [];
    for i = 1:nAxis
        axis = prursg.Engine.Axis();
        axis.title = [ 'axis_' num2str(i)];
        axis.values =  1:size(propertyValue, i);
        axes = [axes axis ]; %#ok<AGROW>
    end
    dseries = prursg.Engine.DataSeries();
    dseries.axes = axes;
    dseries.values = { propertyValue };
end
