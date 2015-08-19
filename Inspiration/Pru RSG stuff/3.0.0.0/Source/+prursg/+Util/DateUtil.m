classdef DateUtil
    %DATEUTIL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function noOfDays =  Days365_shouldnotbecalled(startDate, endDate)
            
           daytotal = [0;31;59;90;120;151;181;212;243;273;304;334]; 
 
            c1 = datevec(startDate); 
            c2 = datevec(endDate); 

            noOfDays = 365 * (c2(:, 1) - c1(:, 1)) + daytotal(c2(:, 2)) - daytotal(c1(:, 2)) + c2(:, 3) - c1(:, 3);  
        end
        
        function noOfDays =  DaysActual(startDate, endDate)            
            noOfDays = datenum(endDate) - datenum(startDate);
        end
        
        %Replace 29/Feb to 28/Feb
        function newDate = ReplaceLeapDate(originalDate)
            newDate = datevec(originalDate);
            if newDate(:, 2) == 2 && newDate(:, 3) == 29
                newDate(:,3) = 28;
            end
            newDate = datenum(newDate);
        end
        
    end
    
end

