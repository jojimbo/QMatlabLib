% A concrete implementation of the IRSGCorrelationMatrixSource interface.
% This class provides support for control file based correlation matrices
classdef CorrelationMatrixControlFileSource < prursg.CorrelationMatrix.IRSGCorrelationMatrixSource & handle
    properties       
        % Ordered names corresponding to Values
        % See IRSGCorrelationMatrixSource:Names
        names = {}
        
        % An [n,n] matrix of ordered values corresponding to Names.
        % See IRSGCorrelationMatrixSource:Values
        values = {}

        % A flag which if set to a value > 0 will output additional log 
        % to aid debugging. Set to zero (the default) to disable; 1 or 2 
        % to increase log output.
        Verbosity = 0;
    end
    
    properties (Access=private)
        % The XML control file DOM from which to extract the correlation
        % matrix
        ControlFileDOM
    end
    
    methods
        % in:
        %   controlFile, An object that implements the IControlFile
        %   interface
        function obj = CorrelationMatrixControlFileSource(controlFile)
            obj.ControlFileDOM = controlFile.controlFileDOM;
        end
        
        % This is a concrete implementation of the abstract
        % IRSGCorrelationMatrixSource readCorrelationMatrix method. It
        % reads a correlation matrix from the input XML control file
        function result = readCorrelationMatrix(obj)
            try
                result = obj.read();
            catch e
                fprintf(['\nCorrelationMatrixControlFileSource:Error: '...'
                    'Caught an exception whilst reading '...
                    'the correlation matrix: \n%s\n'], e.message);
                result = false;
            end
        end
    end
    
    methods (Access=private)
        function result = read(obj)   
            corr_elem = obj.getCorrelationElement();
            obj.javaReadCorrelationMatrix(corr_elem);
            
            % Taken from the old ModelObject class
            % readCorrelationMatrix(xml)
            result = true;
        end
        
        % Java based version
        function result = javaReadCorrelationMatrix(obj, xmlCorrs)
            if ~isempty(xmlCorrs)

                prursg.Xml.configureJava(true);
                obj.values = xml.XmlParser.parseCorrelationMatrix(xmlCorrs);
                
                CORR_SIZE = xmlCorrs.getChildNodes().getLength();
                obj.names = cell(1, CORR_SIZE);
                row = xmlCorrs.getFirstChild();
                for i = 1:CORR_SIZE
                    obj.names{i} = char(row.getAttribute('name'));
                    row = row.getNextSibling();
                end
            end
            result = true;
        end
        
        % Retrieve the correlation matirx 
        function corr_elem = getCorrelationElement(obj)                        
            elements = obj.ControlFileDOM.getElementsByTagName('correlation_matrix');
            if elements.getLength() ~= 1
                fprintf('Error: Found %d correlation_matrix elements\n',...
                        elements.getLength());
                throw(MException('CorrelationMatrixXlsSource:readCorrelationMatrix:MalformedInput',...
                    'Expected one correlation_matrix element in the control file'));
            end
            corr_elem = elements.item(0);
        end   
%{
        % Taken from the old ModelObject class - is this still required?
        % a model file may or may not have a correlation matrix
        function [corrs, resolver] = readCorrelationMatrix(xml)
            import prursg.Xml.*;
            
            corrs = []; resolver = [];
            if ~isempty(xml)
                rows = xml.getChildNodes();
                CORR_SIZE = rows.getLength();
                corrs = zeros(CORR_SIZE);
                riskNames = cell(1, CORR_SIZE);
                
                row = xml.getFirstChild();
                for i = 1:CORR_SIZE
                    %disp(i);
                    riskNames{i} = char(row.getAttribute('name'));
                    %
                    col = row.getFirstChild();
                    for j = 1:CORR_SIZE
                        if isempty(col.getFirstChild())
                            corrs(i,j) = 0;
                        else
                            corrs(i, j) =str2double(col.getFirstChild().getData());
                        end
                        col = col.getNextSibling();
                    end
                    row = row.getNextSibling();
                end
                resolver = prursg.Engine.RiskIndexResolver(riskNames);
            end
        end
%}
    end
end