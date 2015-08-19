%% Linear Interpolation
% *The class returns a set of interpolated values. These values are 
% produced by extrapolating and interpolating an input data series.*
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_LinearInterpolation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% How to use the class
% There are two ways to use this class:
%
% # To produce a one dimensional set of linearly interpolated values from  
% an input data series.
% # To produce a two dimensional set of bilinearly interpolated values from
% an input data series.
%
%
%% Properties
%
% *|[numofDims]|* : The number of dimensions of the input data.
%
% Data type : double
%
% *|[numofAxes]|* : The number of axes used in the input data object. 
% Note that this may differ from the number of dimensions.
%
% Data type : double
% 
% *|[truncate]|* : Either 'true' or 'false'; specifies whether points
% outside the range of the raw data grid should be truncated to the 
% boundaries of the raw data ('true') or found using extrapolation 
% ('false').
%
% Data type : string
%
% *|[newDataSeriesObject]|* : A new data series object, set up to store
% results.
% 
% Data type : -
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        numofDims 
        numofAxes  
        truncate 
        newDataSeriesObject
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of methods
% The class introduces one new method:
%
% *1) |[bootstrap_LinearInterplation()]|* : The class returns a set of 
% linearly interpolated values produced by extrapolating and interpolating
% from an input data series.
%
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    
    % Constructor
    
       function obj = bootstrap_LinearInterpolation ()
         
       end                  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of methods    
%
% *1) |[bootstrap_LinearInterpolation()]|* : The class returns a ZCB yield 
% curve. The yield curve is produced by extrapolating and interpolating raw
% market yield curve data.
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
% 
% *|_Description_|*
%
% The class returns a set of interpolated values produced by extrapolating
% and interpolating from a one or two dimensional input data series.
%
% *|_Inputs_|*
%
% *|DataSeriesIn|* : Contains the raw data series to be used in the
% interpolation procedure.
%
%  Data type : mix of doubles and strings
%
% *|ParametersIn|* : Contains the points to be found via interpolation and
% the *|truncate|* property.
%
%  DAta type : string array
%
% *|_Outputs_|*
% 
% A set of interpolated values produced by extrapolating and interpolating 
% from a one or two dimensional input data series.
% 
% *|_Calculations_|*
%
% After identifying certain characteristics of *|DataSeriesIn|* and
% *|ParametersIn|* and setting up *|newDataSeriesObject|* to store the
% results, the interpolation calculation takes place.
%
% Depending on whether the number of dimensions in use is one or two, the function
% *|LinearArray()|* or *|BiLinearMatrix()|* is called to find the values 
% wanted using either linear or bilinear interpolation respectively.
%
% 
%
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Methods
    
      function results = bs(obj, DataSeriesIn, ParametersIn)                    
              
       % Step 1  :: Set-Up Problem     
           obj.numofDims   = length(size(DataSeriesIn.values{1,1}));
           obj.numofAxes  = size(DataSeriesIn.axes,2);
           obj.truncate = ParametersIn{1};
           newLinearInterp = prursg.Bootstrap.bsLinearInterpolation();
           inumberOfDates =  size(DataSeriesIn(1),1);            
         
       
       % Step 2 ::    Create new data series object
       
           obj.newDataSeriesObject = prursg.Engine.DataSeries_DynamicV3();        
           obj.newDataSeriesObject.dates = DataSeriesIn.dates;   
           obj.newDataSeriesObject.values = cell( inumberOfDates, 1);            
       
       
       % Step 3 :: Calculate values
          
       switch obj.numofDims
           case 1
              
               % Data series object  :: This is an object is created so that
               % we can use the createArrayfromCSVstring function
                newobject = Bootstrap.bootstrap_ZCBtoSwapRate;               
                obj.newDataSeriesObject.axes(1).values = ...
                    newobject.createArrayfromCSVstring(ParametersIn{2}); 
                obj.newDataSeriesObject.axes(1).title = ...
                    DataSeriesIn.axes(1).title;
                if obj.numofAxes == 2
                   obj.newDataSeriesObject.axes(2).values = ...
                       DataSeriesIn.axes(2).values; 
                   obj.newDataSeriesObject.axes(2).title = ...
                       DataSeriesIn.axes(2).title; 
                end   
                
                 % Calculation
               x = obj.newDataSeriesObject.axes(1).values ;              
               X =  DataSeriesIn.axes(1).values;
              
               for i=1:  inumberOfDates
                   Y=DataSeriesIn.values{i,1};
                   % Linear interpolation in one dimesion
                   obj.newDataSeriesObject.values{i,1} = ...
                       newLinearInterp.LinearArray(x ,X ,Y ,obj.truncate);
                  
               end
                
           case 2
               
               
               % Data series object  :: This is object is created so that
               % we can use the createArrayfromCSVstring function
                newobject = Bootstrap.bootstrap_ZCBtoSwapRate;
               
               obj.newDataSeriesObject.axes(1).values = ...
                   newobject.createArrayfromCSVstring(ParametersIn{2}); 
               obj.newDataSeriesObject.axes(2).values= ...
                   newobject.createArrayfromCSVstring(ParametersIn{3});               
               obj.newDataSeriesObject.axes(1).title = ...
                   DataSeriesIn.axes(1).title;
               obj.newDataSeriesObject.axes(2).title = ...
                   DataSeriesIn.axes(2).title;
               if obj.numofAxes == 3
                   obj.newDataSeriesObject.axes(3).values = ...
                       DataSeriesIn.axes(3).values; 
                   obj.newDataSeriesObject.axes(3).title = ...
                       DataSeriesIn.axes(3).title; 
                end  
               
               
               % Calculation
               x = obj.newDataSeriesObject.axes(1).values ;
               y = obj.newDataSeriesObject.axes(2).values ;
               X =  DataSeriesIn.axes(1).values;
               Y =  DataSeriesIn.axes(2).values;
               for i=1:  inumberOfDates
                   Grid =DataSeriesIn.values{i,1};
                   % Linear interpolation in two dimesions
                   obj.newDataSeriesObject.values{i,1} = ...
                       newLinearInterp.BiLinearMatrix(x ,y ,X ,Y ,Grid, ...
                       obj.truncate );
               end
           case 3
               % Linear interpolation in three dimesions
               
           otherwise
               disp(['Invalid Dimension of ' num2str(obj.dimensionofData )])
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

