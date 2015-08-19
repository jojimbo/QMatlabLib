classdef bootstrap_LinearInterpolation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 21/10/2011 Graeme Lawson
    % This class extrapolates and interpolates raw market yield curve data
    % to produce a Zero Coupon Bond (ZCB) yield curve
    
    properties
        numofDims 
        numofAxes  % Number of axes may differ from the number of dimensions
        truncate % constant extrapolation
        newDataSeriesObject
    end
    
    methods
    %%
    % Constructor
    
       function obj = bootstrap_LinearInterpolation ()
         
       end                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
      function results = bs(obj,DataSeriesIn, ParametersIn)                    
              
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Step 1  :: Set-Up Problem     
           obj.numofDims   = length(size(DataSeriesIn.values{1,1}));
           obj.numofAxes  = size(DataSeriesIn.axes,2);
           obj.truncate = ParametersIn{1};
           newLinearInterp = prursg.Bootstrap.bsLinearInterpolation();
           inumberOfDates =  size(DataSeriesIn(1),1);            
         
       %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Step 2 ::    Create new data series object
       
           obj.newDataSeriesObject = prursg.Engine.DataSeries_DynamicV3();        
           obj.newDataSeriesObject.dates = DataSeriesIn.dates;   
           obj.newDataSeriesObject.values = cell( inumberOfDates, 1);            
       
       %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Step 3 :: Calculate values
          
       switch obj.numofDims
           case 1
              
               % Data series object  :: This is an object is created so that
               % we can use the createArrayfromCSVstring function
                newobject = prursg.Bootstrap.bootstrap_ZCBtoSwapRate;               
                obj.newDataSeriesObject.axes(1).values = newobject.createArrayfromCSVstring(ParametersIn{2}); 
                obj.newDataSeriesObject.axes(1).title = DataSeriesIn.axes(1).title;
                if obj.numofAxes == 2
                   obj.newDataSeriesObject.axes(2).values = DataSeriesIn.axes(2).values; 
                   obj.newDataSeriesObject.axes(2).title = DataSeriesIn.axes(2).title; 
                end   
                
                 % Calculation
               x = obj.newDataSeriesObject.axes(1).values ;              
               X =  DataSeriesIn.axes(1).values;
              
               for i=1:  inumberOfDates
                   Y=DataSeriesIn.values{i,1};
                   % Linear interpolation in one dimesion
                   obj.newDataSeriesObject.values{i,1} = newLinearInterp.LinearArray( x ,  X , Y ,obj.truncate );
                  
               end
                
           case 2
               
               
               % Data series object  :: This is object is created so that
               % we can use the createArrayfromCSVstring function
                newobject = prursg.Bootstrap.bootstrap_ZCBtoSwapRate;
               
               obj.newDataSeriesObject.axes(1).values = newobject.createArrayfromCSVstring(ParametersIn{2}); 
               obj.newDataSeriesObject.axes(2).values= newobject.createArrayfromCSVstring(ParametersIn{3});               
               obj.newDataSeriesObject.axes(1).title = DataSeriesIn.axes(1).title;
               obj.newDataSeriesObject.axes(2).title = DataSeriesIn.axes(2).title;
               if obj.numofAxes == 3
                   obj.newDataSeriesObject.axes(3).values = DataSeriesIn.axes(3).values; 
                   obj.newDataSeriesObject.axes(3).title = DataSeriesIn.axes(3).title; 
                end  
               
               
               % Calculation
               x = obj.newDataSeriesObject.axes(1).values ;
               y = obj.newDataSeriesObject.axes(2).values ;
               X =  DataSeriesIn.axes(1).values;
               Y =  DataSeriesIn.axes(2).values;
               for i=1:  inumberOfDates
                   Grid =DataSeriesIn.values{i,1};
                   % Linear interpolation in two dimesions
                   obj.newDataSeriesObject.values{i,1} = newLinearInterp.BiLinearMatrix( x , y , X ,  Y , Grid, obj.truncate );
               end
           case 3
               % Linear interpolation in three dimesions
               
           otherwise
               disp( ['Invalid Dimension of ' num2str(obj.dimensionofData )])
       end
       
       %%
       %''''''''''''''''''''''''''''''''''''''''''%
       % Step 4 ::    Output Data series
            
         results = obj.newDataSeriesObject;
       
        %''''''''''''''''''''''''''''''''''''''''''%
        %%
      end
    
    end
    
end

