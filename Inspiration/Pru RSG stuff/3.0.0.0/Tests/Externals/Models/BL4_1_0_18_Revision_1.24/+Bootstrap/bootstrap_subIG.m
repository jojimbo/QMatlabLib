%% SYNTHETIC SUB INVESTMENT GRADE CREDIT SPREADS
% *The class returns estimates of sub-investment grade bond spreads by interpolating
% and extrapolating investment grade spreads.*
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_subIG < prursg.Bootstrap.BaseBootstrapAlgorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method produces sub-investment grade 
% bond spreads by applying interpolation and extrapolation to market investment grade 
% spreads.
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *|[InputIGCreditIndex]|* : Input investment grade credit index from which sub investment
% grade spreads are derived
%
% _Data Type_: 1-dim array
%
% *|[InputIGCreditIndex_Proxy]|* : Proxy investment grade credit index when
% an index is not available for that currency
%
% _Data Type_: 1-dim array
%
% *|[subIGratings]|* : List of sub-investment grade ratings required,
% separated by commas
%
% _Data Type_: string
%
% *|[baseIndexValue]|* : base credit index value, e.g. "10,000" 
%
% _Data Type_: double
%
% *|[recoveryRate]|* : assumed portion of notional that can be recovered in situation of default
%
% _Data Type_: double
%
% *|[durationAtDefault]|* : assumed duration at which default occurs
%
% _Data Type_: double
%
% *|[subIGIndexAxis]|* : axis value of output indices, e.g. "spread", "OAS"
%
% _Data Type_: string
%
% *|[numOfInputIndex]|* : number of investment grade indices inputted in
%
% _Data Type_: double
%
% *|[subIGInterp]|* : whether investment grade credit indices need interpolation in the middle, "TRUE" or "FALSE"
%
% _Data Type_: string
%
% *|[interpRatingFactor]|* : use 1 or 0 to indicate which investment grade 
% rating needs interpolation, e.g. for total 5 investment grades, "0,0,1,1,0" 
% means A- and BBB- rated credit indices needs interpolation
%
% _Data Type_: string
%
% *|[subIGProxy]|* : whether investment grade credit indices need proxy at the end, "TRUE" or "FALSE"
%
% _Data Type_: string
%
% *|[lastAvailableRating]|* : last investment grade rate available, e.g. "BBB", "A"
%
% _Data Type_: string
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     properties
         
         % Data Series
         InputIGCreditIndex
         InputIGCreditIndex_Proxy
         
         % Parameters     
         subIGRatings
         baseIndexValue % assumed 10,000
         recoveryRate
         durationAtDefault
         subIGIndexAxis
         numOfInputIndex
         subIGInterp
         interpRatingFactor
         subIGProxy
         lastAvailableRating
         
     end
%% List of Methods
% The class introduces one new method:
%
% *|1)[Bootstrap()]|* : The class produces sub-investment grade bond spreads 
% by applying interpolation and extrapolation to market investment grade 
% spreads.
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
    % Constructor
    
       function obj = bootstrap_subIG ()
           obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
       end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%% Details of Methods
%
% *1) [Bootstrap()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *|_Description_|*
%
% The class returns estimates of sub-investment grade bond spreads partly 
% based on extrapolation from investment grade bond spread data.
%
% *|_Inputs_|*
%
% *|[DataSeriesIn]|* - Input investment grade credit indicies
% 
% _Data Type_: all 1-dim array bond index
% 
% *|_Outputs_|*
% 
% Bond spreads from AAA to D
%
% _Data Type_: 1-dim array
% 
% *|_Calculations_|*
%
% STEP 1: Allocate input credit index values into corresponding rating buckets
%
% If input credit indices do not fill all the investment grade
% rating buckets, i.e. AAA, AA, A and BBB, linear interpolation and/or 
% extrapolation are used to complete the buckets.
%
% STEP 2: In the case that there are gaps between investment grade ratings, linear 
% interpolation is applied to fill the gaps.
% 
% STEP 3: In the case that the ratings at the end are not available,
% extrapolation is applied based on proxy credit index values.
%
% STEP 4: This is the main calculation step to derive sub investment grade
% spreads
%
% First, calculate the spread of the lowest rating D (default rating) using 
% an assumed baseIndexValue $10,000$, recovery rate, $R$ and default duration, $t$, 
%
% $$ D = 10,000 \times (R ^ { -1 /t } -1 )$$
%
% To find the spreads for the ratings between the last investment grade and the 
% default rating, linear interpolation is applied.
%
% The output is a 1-dim array with ratings from AAA to D as the axis values
% and the corresponding spreads for each rating as data points.
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
    function results = Bootstrap(obj, DataSeriesIn)

        inumberOfDates = size(DataSeriesIn(1).dates,1);
        numOfDataSeries = size(DataSeriesIn,2);
        
        results = DataSeriesIn(1).Clone;
        results.axes.values = {'AAA' 'AA' 'A' 'BBB' 'BB' 'B' 'CCC' 'CC-C' 'D'};
        numOfRatings = size(results.axes.values,2);
        lastAvRatingPos = strmatch(obj.lastAvailableRating, ...
            results.axes.values,'exact');
        lastIGRatingPos = strmatch('B',results.axes.values,'exact');
        
        obj.InputIGCreditIndex = prursg.Engine.DataSeries();
        
        for t = 1:inumberOfDates
            
            % step 1: allocate input credit index values into corresponding rating buckets
            
            for n = 1 : obj.numOfInputIndex
                obj.InputIGCreditIndex.values{t}(strmatch ...
                    (DataSeriesIn(n).rating,results.axes.values,'exact'))...
                    =DataSeriesIn(n).values{t}(strmatch ...
                    (obj.subIGIndexAxis,DataSeriesIn(n).axes.values));
            end
            
            for n = lastAvRatingPos + 1 : lastIGRatingPos
                obj.InputIGCreditIndex.values{t}(n) = ...
                    obj.InputIGCreditIndex.values{t}(lastAvRatingPos);
            end
            
            for n = lastIGRatingPos + 1 :numOfRatings
                obj.InputIGCreditIndex.values{t}(n) = 0;
            end
            
            
            
            % step 2: interpolate
            if strcmp(obj.subIGInterp, 'True')
                interpPosition = find(str2num(obj.interpRatingFactor)>0);
                
                for i = 1 : size(interpPosition, 2)
                    for j = i : size(interpPosition, 2)
                        interval = 2;
                        if size(interpPosition, 2)>1 && interpPosition(j) - interpPosition(j+1) == -1
                            interval = interval + 1;
                        end
                    end
                    
                    k = interpPosition(i);
                    
                    obj.InputIGCreditIndex.values{t}(k) = ...
                        obj.InputIGCreditIndex.values{t}(k-1) + ...
                        (obj.InputIGCreditIndex.values{t}(k-1+interval) - ...
                        obj.InputIGCreditIndex.values{t}(k-1)) / interval;
                    
                end    
            end
            
            results.values{t} = obj.InputIGCreditIndex.values{t};
            
            % step 3: proxy
            if strcmp(obj.subIGProxy, 'True')
                
                proxyIndex1 = prursg.Engine.DataSeries();
  
                for i = 1 : numOfDataSeries - obj.numOfInputIndex
                    proxyIndex1.values{t}(lastAvRatingPos + i) = ...
                        DataSeriesIn(obj.numOfInputIndex + i).values{t}...
                        (strmatch(obj.subIGIndexAxis,DataSeriesIn ...
                        (obj.numOfInputIndex+i).axes.values));
                end
                
                proxyIndex2.values{t} = [proxyIndex1.values{t}(1, 2 :end) 0];
                proxyFactor = proxyIndex2.values{t}./proxyIndex1.values{t};
                
                for j = lastAvRatingPos + 1 : lastIGRatingPos
                    results.values{t}(j) = results.values{t}(j-1).* ...
                        proxyFactor(j);
                end        
                
            end
            
            % step 4: derive subIG
            
            D = obj.baseIndexValue * (obj.recoveryRate ^ ...
                ( -1 / obj.durationAtDefault ) -1 );
            numOfSubIG = size(strfind(obj.subIGRatings,','),2)+1;
            delta = (D/results.values{t}(lastIGRatingPos))^(1/numOfSubIG);
            
            for i = lastIGRatingPos + 1 : numOfRatings
                results.values{t}(i) = results.values{t}(i-1)*delta;
            end
            
        end

        results.Name = '';
        results.source ='iMDP';
        results.ticker= 'na';      
        results.description = 'derived subIG method';
        results.units ='bps';
        results.rating ='na';

     end
                  
        

    end
    
end

