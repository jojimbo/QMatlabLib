classdef ExcelIssues
    %EXCELISSUES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function riskNames = getExcelRiskNamesOrder()
            %riskNames = importdata(fullfile('+prursg', '+Test', '+UseCase', 'excel_risks_order.txt'));                        
            riskNames = importdata(fullfile('+prursg', '+Test', '+UseCase', 'bb_excel_order.txt'));                                    
        end
        
    end
    
end

