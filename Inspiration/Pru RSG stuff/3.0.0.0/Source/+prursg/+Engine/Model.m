classdef Model < handle
    %PRURSG.MODEL  Abstract base class for models
    %   Class representing a parameterized model that produces output using 
    %   stochastic time series data.
    
    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.11 $  $Date: 2011/06/09 12:13:42BST $

    
    properties ( SetAccess = protected )
        name % Name of the model (string).  Can be used for filtering.
        initialValue % an instance of DataSeries class
    end
            
    properties
        simEngine % can consider removing

        calibrationSource % instance of CalibrationSource class, used for calibration onto historic dataseries
        calibrationTargets % an array of CalibrationTarget objects, used for calibration onto percentiles
    end
    
    properties ( Access = private )
        precedents % a map of all precedent risks for this model map<paramname, risk.name>
    end
        
    methods ( Access = protected )
        function obj = Model(name)
            % Model - Constructor
            %   obj = Model( name, pnames, ID )
            % Inputs:
            %   name - name of model
            obj.name = name;
            obj.precedents = containers.Map();
        end
    end
    
        
    methods 
        
        % values could be scalar, vector or matrix.
        % we need a Type deductor here.
        function setInitialValue(obj, values)
            obj.initialValue = values;
        end
        
        function addDependency(obj, parameterName, precedentRiskFactorName)
            obj.precedents(parameterName) = precedentRiskFactorName;
        end
        
        function precedentNames = getPrecedentNames(obj)
            precedentNames = values(obj.precedents);
        end
        
        function precedentObj = getPrecedentObj(obj)
            % given the name tag of a precendent, retrive precedent risk
            % name in the precedent map object
            precedentObj = obj.precedents;
        end
        
         %debug function
        function dumpDependencies(obj)
            k = keys(obj.precedents);
            v = values(obj.precedents); 
            disp(obj.name);
            for i = 1:length(k)
                disp(['<', k{i}, ', ', v{i}, '>']);
            end
            disp('');
        end
        
         % Deserializes the model from a xml DOM element uses an automatic 
        % mapping scheme that maps object's public properties into xml tags
        % xml - the xml DOM element.
        %
        % Model properties which are not to be (de)serialised, should be
        % declared private, protected or transient: (properties (Transient =
        % true))
        function fromXml(obj, xml)
            prursg.Xml.ModelDao.fromXml(obj, xml);            
        end
        
        % Merges the model into a xml DOM element uses an automatic mapping 
        % scheme that maps object's public properties into xml tags.
        % The contents of xml tags corresponding to model's properties, are
        % automatically replaced with model's properties values.
        %
        % Model properties which are not to be serialised, should be
        % declared private, protected or transient: (properties (Transient =
        % true))
        function toXml(obj, xml)
            prursg.Xml.ModelDao.toXml(obj, xml);
        end       
    end
    
    
    methods ( Abstract )

        % Perform calibration
        calibrate(obj, series) 
        % series is the calibration data, last element is the most
        % recent
                
        inputs = getNumberOfStochasticInputs(obj)
        outputs = getNumberOfStochasticOutputs(obj)
        
        % Perform simulation
        % the simulation data is taken from the simulationEngine object
        series  = simulate( obj ) 
        
        % Display goodness of fit
        s = validateCalibration( obj );
        
    end
    
end

