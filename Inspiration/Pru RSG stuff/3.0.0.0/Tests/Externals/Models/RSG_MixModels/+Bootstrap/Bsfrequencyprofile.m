classdef Bsfrequencyprofile < handle
    % Creates a frequency profile based on an string format
    
    properties
      interval = [];  
      maxterm  = [];  
    end
           
    methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  % Constructor       
        function obj = Bsfrequencyprofile(frequencystring,maxterm)
            % Set the frequency for each interval   
            obj.interval(1,2) = 1/12;       % Months
            obj.interval(2,2) = 1/4;     % Quarters
            obj.interval(3,2) = 1/2;  % Halfyears 
            obj.interval(4,2) = 1;      % Years 
            
             Pos = findstr(frequencystring,',');
            
            % Extract M, Q, SA, & A profile from string
           obj.interval(1,1) = str2num(frequencystring(1:Pos(1)-1));       % Months
           obj.interval(2,1) = str2num(frequencystring(Pos(1)+1:Pos(2)));     % Quarters
           obj.interval(3,1) = str2num(frequencystring(Pos(2)+1:Pos(3)));  % Halfyears 
           obj.interval(4,1) = str2num(frequencystring(Pos(3)+1:length(frequencystring)));      % Years    
           
           obj.maxterm =maxterm;
        end
      
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 % Adjust intervals allowing for maxterm    
 
        function y = AdjustedIntervalCount(obj)            
                   
                y = obj.interval;
                 MaxMonths = floor(obj.maxterm/y(1,2));                 

                       for i = 1 : size( obj.interval ,1)
                           sum1 = 0;
                         for j= 1 : size( obj.interval ,1)  
                                 if ne(j,i)
                                   sum1 =  sum1 + obj.interval(j,1);
                                 end
                         end                                                   
                         
                         if sum1 == 0 
                             y(i,1) = max(obj.interval(i,1), obj.maxterm/y(i,2));                             
                         else
                              sum2 = 0;
                             for j= i+1 : size( obj.interval ,1)  
                                 if ne(j,i)
                                   sum2 =  sum2 + obj.interval(j,1);
                                 end
                              end
                             
                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                             
                              maxRemainingInterval= max(0, MaxMonths*y(1,2)/y(i,2));
                              
                             if sum2 == 0
                                  y(i,1)=  maxRemainingInterval;
                             else
                                  y(i,1)=  min(y(i,1), maxRemainingInterval); 
                             end
                                                          
                         end    
                            y(i,1)= floor(y(i,1));  
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Calculate the residual number of months                            
                            MaxMonths = MaxMonths - y(i,1)*( y(i,2)/obj.interval(1,2));                            
                       
                       end
                          
                return 
        end
        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 % Interval Array
 
     function z = AdjustedIntervalArray(obj)
                  
         AdjustedCounts = AdjustedIntervalCount(obj) ;
         aux = sum(AdjustedCounts,1);
         z = zeros (aux(1),1);
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Calculate incremental profile
          count = 0;                  
           for i = 1 :  size(AdjustedCounts ,1)
               for j = 1 : AdjustedCounts(i,1)
                   count = count +1;
                  z(count) = AdjustedCounts(i,2);
               end    
           end
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Calculate cumulative profile
            
          for i = 2 :  size(z ,1)
              z(i) = z(i-1) + z(i);
          end    
           
          return
     end    
     
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 % Create a cut down dataseriesobjected based on the adjusted interval array
 % Search is over all three axes - axes are assumed to be numeric
     
    function z = SmallerDataSeriesObject(obj, AxesArraytoMatch, DataSeriesObject)
                  
      
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Calculate incremental profile         
          SearchStartIndex = 1;          
          SearchTolerance = 0.00001;
          
           for i = 1 :  size(AxesArraytoMatch, 1)
               SearchItem = AxesArraytoMatch(i , 1 : size(AxesArraytoMatch, 2));
               SearchEndIndex = size(DataSeriesObject.values{1},2);
               
               for j = SearchStartIndex : SearchEndIndex                  
                                       
                    sum1 = sqrt(   sum((SearchItem - DataSeriesObject.axes.values(:,j)).^2) );
                   
                  if sum1 < SearchTolerance
                      SearchStartIndex= j+1;
                      SearchEndIndex = j;                         
                      for k = 1 : size(DataSeriesObject.dates, 1)
                        NewValues{k,1}(i) =DataSeriesObject.values{k,1}(j); 
                      end 
                 end                     
               end    
           end
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Create New Dataseries object
           import prursg.Engine.*;
            allAxis = [];
           for i = 1 : size(DataSeriesObject.axes,1)
                axis = Axis();
                axis.title = DataSeriesObject.axes(i).title;
                axis.values = AxesArraytoMatch(:,i);
                allAxis = [allAxis axis];           
           end   
                            
            dataObj = DataSeries();
            dataObj.axes = allAxis;
            dataObj.values = NewValues;
            dataObj.dates = DataSeriesObject.dates;
            
            z  = dataObj;
           
          return
     end    
     
     
     
     
    end
    
end



