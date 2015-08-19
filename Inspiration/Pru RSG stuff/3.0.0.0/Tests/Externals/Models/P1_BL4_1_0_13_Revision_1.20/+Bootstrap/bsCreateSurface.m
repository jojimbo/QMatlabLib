classdef bsCreateSurface
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor  
    
    %--------------------------------------------------------%
        function obj =  bsCreateSurface(xdata1, ydata1, zdata1, surfacename, charttitle, xtitle, ytitle, ztitle)
            %CREATEFIGURE(XDATA1,YDATA1,ZDATA1)
            %  XDATA1:  surface xdata
            %  YDATA1:  surface ydata
            %  ZDATA1:  surface zdata
            
            % Create figure
            figure1 = figure;
               
            surf( xdata1 , ydata1, zdata1,'DisplayName',surfacename);figure(gcf)            
         
            % Create xlabel
            xlabel({xtitle});
            
            % Create ylabel
            ylabel({ytitle});
            
            % Create zlabel
            zlabel({ztitle});
            
            % Create title
            title({charttitle});
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods and functions    
        
       
    end

end
