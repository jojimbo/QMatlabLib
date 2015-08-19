classdef XPathDoc < handle
    %XPATHUTIL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        doc        
        xpath
    end
    
    methods
        function obj = XPathDoc(filename)
        
            import javax.xml.parsers.*;
            import javax.xml.xpath.*;
                                        
            docBuilderFactory = DocumentBuilderFactory.newInstance();
            docBuilderFactory.setNamespaceAware(1);
            docBuilder = docBuilderFactory.newDocumentBuilder();            
            
            xpathFactory = XPathFactory.newInstance();
            obj.xpath = xpathFactory.newXPath(); 
            
            obj.doc = docBuilder.parse(filename);
                        
        end
        
        function [result xpathExpression] = Evaluate(obj, expression, xpathConstant, varargin)
            import javax.xml.parsers.*;
            import javax.xml.xpath.*;
            
            xpathExpression = obj.xpath.compile(expression);
            if size(varargin, 2) > 0
                result = xpathExpression.evaluate(varargin{1}, xpathConstant);  
            else
                result = xpathExpression.evaluate(obj.doc, xpathConstant);
            end                                    
        end
        
    end
    
end

