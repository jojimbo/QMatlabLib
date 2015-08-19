classdef bsLineGraph < handle
    
    % Creates Line graphs according to a mixture of defaults and user
    % specified values
    
    % Note we need the handle class in order to modify the property values
    % of the class   
    
    
    % The class has the following varible arguments 'xlimits', 'ylimits',
    % 'zlimits' ,'flimits', 'lineStyleOrder', 'lineStyleColorOrder'
     
        
    
     properties (Access = private)
            
       % colorCell :: Defaults Values    
       % r = Red, g = Green, b= Blue, bl = Black, dr = Dark Red, 
       % dg = Dark Green, db = 'Dark Blue 
       
       colorCell = { 'red', [ 1 0 0],; 'green' , [ 0 1 0],; 'blue', [ 0 0 1],; ... 
                       'black',  [0 0 0]; 'dred', [ 0.5 0 0],; 'dgreen' , [ 0 0.5 0],; 'dblue', [ 0 0 0.5] }
        
       colorOrder 
         
     end    
    
          
     properties (Access = public)
        
        % Default line Styles  
        % s = Square, d = Diamond, ^ = upper triangle
        % V= Lower triangle, p = pentangle, h = hexagon
        lineStyleColorOrder
        lineStyleOrder ='--s,--d,--^, --V,--p,--h'; % Use comma seperate variable format :: as the input is likely to arrive via spreadsheet
                                                    % Also lineStyleOrder contains a list of the line type and marker            
        
        xlimits
        ylimits
        zlimits
        flimits
                      
    end
     
     
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor  
    
    %--------------------------------------------------------%
        function obj =  bsLineGraph()
             % Set-Up Default Color Order
             NumberOfColors = size(obj.colorCell(: , 2) ,1);
             obj.colorOrder = []; % allocate storage space
             
             for i = 1 : NumberOfColors
                 obj.colorOrder  =[ obj.colorOrder;  obj.colorCell{i , 2}];
             end
             
             obj.lineStyleColorOrder =obj.colorCell(: , 1);
        end
        
              
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Regular Methods and functions :: These methods need to about the
    % instance of the class
                
               
        function  MultipleLineGraph(obj,xdata1, ydata1, dataSeriesNames ,plotname, charttitle, xtitle, ytitle, varargin)
           
            % Update parameters/ properties   
             if isempty(varargin) == 0
              obj.variableArgumentList(varargin)
             end
            % Create new figure
            figure1 = figure;
            
            % Create axes
            axes1 = axes('Parent',figure1);
              
            set(gcf,'DefaultAxesColorOrder',obj.colorOrder,...
                           'DefaultAxesLineStyleOrder',strrep(obj.lineStyleOrder, ',' , '|') );             
                                             
            plot( xdata1{1} , ydata1{1},'DisplayName',plotname);% figure(gcf)
            hold all % Command prevents the axis color and line style from being reset
            % Additional data to the plot :: use Line Specification in the
            % MatLAb help for explanantion of parameters and settings
            
            for i =2 : size(xdata1 ,2)               
                plot( xdata1{i} , ydata1{i})
            end
            
            % Set Upper and lower bound for the y-axis            
            if isempty(obj.flimits) == 0               
                ylim(axes1,obj.flimits);
            end
            
            % Turn on legend
            legend on;
            legend_handle = legend( dataSeriesNames);
            
            % Turn off legend box nad place in the bottom right corner
            
            set(legend_handle, 'Box', 'off','Location','SouthEast')
            
            % Create xlabel
            xlabel({xtitle});
            
            % Create ylabel
            ylabel({ytitle});
            
            % Create title
            title(charttitle,...
                'FontName','Arial', 'BackgroundColor',[1 1 1]);
            
            hold off
            
            
        end
        
        function variableArgumentList(obj,varargin)
            
             % Create by Graeme Lawson on 05/04/2012
             % Abstract variable arguments from varagin and sets default
             % behaviour if required
             % 1st Column of varargin contains the field/property description, the second, third, ... column contains      
             % the values of the properties for each data-series                            
                          
            if isempty(varargin) == 0  
                
                 data = varargin{1,1}{1,1};
                 vararginNames = data(: , 1);
                                      
                     Index = strmatch( 'xlimits', vararginNames);
                     if Index > 0
                         obj.xlimits = data{Index(1,1), 2};
                     end
                     
                     Index = strmatch( 'ylimits', vararginNames);
                     if Index > 0
                         obj.ylimits = data{Index(1,1), 2};
                     end
                     
                     Index = strmatch( 'zlimits', vararginNames);
                     if Index > 0
                         obj.zlimits =data{Index(1,1), 2};
                     end
                     
                     Index = strmatch( 'flimits', vararginNames);
                     if Index > 0
                         obj.flimits = data{Index(1,1), 2};
                     end
                     
                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                     % Update line property values if the user has specified
                     % there own properties                     
                                                             
                         Index = strmatch( 'lineStyleOrder', vararginNames);
                         if Index > 0
                             obj.lineStyleOrder = data{Index(1,1), 2};                            
                         end                                               
                         
                         Index = strmatch( 'lineStyleColorOrder', vararginNames);
                         if Index > 0
                             CSVstring =data{Index(1,1), 2};
                             pos = findstr(CSVstring,','); % find position of the commons in our CSV
                             NumberOfColors =  size(pos,2)+1;
                             obj.colorOrder = []; % allocate storage space
                             
                             pos = [ 0 pos (length(CSVstring)+1)] ; % We will use this array to index our colors
                             
                             for i = 1 :  NumberOfColors 
                                ColorIndex(1,1) = strmatch(CSVstring(pos(i)+1: pos(i+1) -1) ,obj.lineStyleColorOrder);
                                if ColorIndex(1,1) > 0 
                                   obj.colorOrder= [obj.colorOrder; obj.colorCell{ColorIndex(1,1),2}] ;
                                else % Create a distince default color if we cannot find a match
                                   obj.colorOrder= [obj.colorOrder; [ i/(numberOfColors+1) 0 1 - i/(NumberOfColors+1) ]] ;
                                end    
                             end 
                             % Update property to reflect users choice 
                             obj.lineStyleColorOrder = CSVstring;
                         end
                         
                         
                         
            end
        end    
        
    end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Static Methods & Functions :: do not need to know about the instance
    % of the class
    
    methods (Static = true)
        
        
         function SingleLineGraphOld(xdata1, ydata1, plotname, charttitle, xtitle, ytitle, varargin)
            %CREATEFIGURE(XDATA1,YDATA1)
            %  XDATA1:  plot xdata
            %  YDATA1:  plot ydata
            
            % Create new figure
            figure1 = figure;
            
            % Create axes
            axes1 = axes('Parent',figure1);
            
            plot( xdata1 , ydata1,'Marker','square','LineStyle','none','DisplayName',plotname);figure(gcf)
            
            
            if isempty(varargin) == 0
                ylimits = varargin{1,1}{1,2};
                ylim(axes1,ylimits);
            end
            
            % Create xlabel
            xlabel({xtitle});
            
            % Create ylabel
            ylabel({ytitle});
            
            % Create title
            title(charttitle,...
                'FontName','Arial', 'BackgroundColor',[0.749019607843137 0.749019607843137 0]);
            
            
        end
        
                
        function  MultipleLineGraphOld(xdata1, ydata1, dataSeriesNames ,plotname, charttitle, xtitle, ytitle, varargin)
           
                        
            % Create new figure
            figure1 = figure;
            
            % Create axes
            axes1 = axes('Parent',figure1);
            
           plot( xdata1{1} , ydata1{1},'Marker','square','LineStyle','none','DisplayName',plotname);figure(gcf)
           hold
            % Additional data to the plot :: use Line Specification in the
            % MatLAb help for explanantion of parameters and settings
            
            for i =2 : size(xdata1 ,2)
                plot( xdata1{i} , ydata1{i},'Marker', 'square' ,'LineStyle','none')               
            end
                                              
            if isempty(varargin) == 0
                ylimits = varargin{1,1}{1,2};
                ylim(axes1,ylimits);
            end
                        
            % Turn on legend
            legend on;
            legend( dataSeriesNames);
            
            % Create xlabel
            xlabel({xtitle});
            
            % Create ylabel
            ylabel({ytitle});
            
            % Create title
            title(charttitle,...
                'FontName','Arial', 'BackgroundColor',[0.749019607843137 0.749019607843137 0]);
            
          end
        
    end       
    
end


