classdef BsSort < handle
    % Created by Graeme Lawson on 18/12/12
    % The class sorts an array based on the core shell sort algorithms
    
    properties
       
    end
    
    methods
     %% Constructor
     
     function obj = BsSort()
        
     end    
                
     %% Functions and Methods   
     
       function outputDataSeries = SortDataSeries(obj,DataSeriesIn)
          % Created by Graeme Lawson on the 15/02/12 :: Purpose is sort 1-
          % 2 D data according to there axis values :: Note axis values are
          % assumed to be numeric
          
           outputDataSeries = DataSeriesIn.Clone();       
           iNumberOfDataSeries = size(DataSeriesIn, 2) ;
           
           
           for i = 1 :  iNumberOfDataSeries
                inumberOfDates = size(DataSeriesIn(i).dates, 1);
                 iNumberofAxis = size(DataSeriesIn(i).axes, 2);                 
                                  
                 
             for j= 1 :  inumberOfDates
                 
                 if iNumberofAxis == 1 
                                          
                     if iscellstr( DataSeriesIn(i).axes(1).values)
                       AxisValues1=  str2num(char(DataSeriesIn(i).axes(1).values))';
                     else
                       AxisValues1 = cell2mat(DataSeriesIn(i).axes(1).values);  
                     end
                     
                     Values = DataSeriesIn(i).values{j};
                     % Sort by 1st Axis                  
                    
                     sortedData =  obj.ShellSort2( [AxisValues1 ;  Values] ,2);     
                     outputDataSeries(i).axes(1).values = num2cell(sortedData(1,1:end));
                     outputDataSeries(i).values{j} = sortedData(2,1:end);
                     
                 elseif iNumberofAxis == 2
                     
                     if iscellstr( DataSeriesIn(i).axes(1).values)
                       AxisValues1=  str2num(char(DataSeriesIn(i).axes(1).values))';
                     else
                       AxisValues1 = cell2mat(DataSeriesIn(i).axes(1).values);  
                     end
                     
                     if iscellstr( DataSeriesIn(i).axes(1).values)
                       AxisValues2=  str2num(char(DataSeriesIn(i).axes(2).values))';
                     else
                       AxisValues2 = cell2mat(DataSeriesIn(i).axes(2).values);  
                     end
                                         
                     Values = DataSeriesIn(i).values{j};
                     % Sort by 2nd Axis
                     sortedData =  obj.ShellSort2( [AxisValues2;  Values ] ,2);            
                     outputDataSeries(i).axes(2).values = num2cell(sortedData(1, 1:end));
                      % Sort by 1st Axis 
                     sortedData =  obj.ShellSort2( [AxisValues1' ,  sortedData(2:end, 1:end)] ,1);     
                     outputDataSeries(i).axes(1).values = num2cell(sortedData(1:end,1)');
                     outputDataSeries(i).values{j} = sortedData(1:end,2:end);
                                          
                 end     
                 
             end 
           end    
               
       end
     
     
        function outputArray = ShellSort2(obj,inputArray, dimension)
            % Created by Graeme Lawson on the 17/12/12
            % Function sorts either a matrix according to one row or column
            % moving all other remaining elements in the row/column in
            % to the adjacent position
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 0 :: Transpose matrix into the required row set-up for
            % sorting via the main algorithm
            
            if dimension == 1 
                % Sort matrix by the first column
                array = inputArray;
            elseif dimension == 2
                % Sort matrix by the first row
                array = inputArray';
            end     
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 1 :: Begin Main Sorting Algorithm
            
            LRow = 1;
            URow = size(array, 1);
            
            Temp = zeros( 1, size(array, 2));     % Allocate storage space       
            Increm = 1;
            
             while  Increm  <= (URow - LRow)
                 Increm = 3 * Increm + 1;
             end
                     
             Increm = round(Increm / 3);
             
            while (Increm >= LRow)
                
                %This is the insertion sort algorithm
                for i = (Increm + LRow) : URow                     
                  
                        Temp(1, :) = array(i, :) ; % Stores Temp Values                                                  
                        
                        j = i  ;    
                              while array(j - Increm,1) > Temp(1,1)                                 
                                 array(j , :) = array(j- Increm, :);
                                 j = j - Increm;
                                 if j <= Increm 
                                     break 
                                 end ;
                              end     
                        array(j  , : ) = Temp;                         
                end
               
                Increm = round(Increm / 3); % Reduce the size of the increment
            end
                        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2 :: Ouput Result transpong if necessary
             if dimension == 1 
                % Sort matrix by the first column
                outputArray = array;
            elseif dimension == 2
                % Sort matrix by the first row
                outputArray = array';
            end 
            
           
            return
            
        end
        
        
        
        
        
    end
    
end

