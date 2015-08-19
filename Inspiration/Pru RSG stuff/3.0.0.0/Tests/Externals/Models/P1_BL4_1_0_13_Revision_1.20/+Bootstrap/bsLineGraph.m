classdef bsLineGraph
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor  
    
    %--------------------------------------------------------%
        function obj =  bsLineGraph(xdata1, ydata1, plotname, charttitle, xtitle, ytitle)
            %CREATEFIGURE(XDATA1,YDATA1)
            %  XDATA1:  plot xdata
            %  YDATA1:  plot ydata
                       
            % Create figure
            figure1 = figure;
               
            plot( xdata1 , ydata1,'DisplayName',plotname);figure(gcf)            
            
            
            
            % Create xlabel
            xlabel({xtitle});
            
            % Create ylabel
            ylabel({ytitle});                       
            
            % Create title
            title({charttitle});
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods and functions    
        
       
    end

end
