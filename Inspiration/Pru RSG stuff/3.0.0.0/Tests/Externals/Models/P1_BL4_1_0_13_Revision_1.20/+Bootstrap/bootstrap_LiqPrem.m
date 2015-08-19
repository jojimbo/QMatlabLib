classdef bootstrap_LiqPrem < handle
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     % Enter Description
    properties
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % Data Series 
        
        % for Pillar I calculation
        InputCorpGovSpread = []; % annual benchmark indices from Markit1
        InputSwapGovSpread = []; % bbg
        
        % for Pillar II USD calculation
        InputUS_10ySwap = []; % for swap-spread adjustment
        InputUS_CorpCMLYield = []; % bbg
        InputUS_CMBSGovSpread = []; % bbg 
        InputUS_ABSCMOGovSpread = []; % bbg 
        InputUS_CorpAllocation = []; % Jackson's Corporate Bond exposure 
        InputUS_CMLAllocation = []; % Jackson's CML exposure
        InputUS_CMBSAllocation = []; % Jackson's CMBS exposure
        InputUS_ABSAllocation = []; % Jackson's ABS exposure

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % Parameters 
       
        OutputFrequency = []; % string representing frequency profile
        OutputCompounding = []; % Simple, Annualized, Continuous
        OutputCompoundingFrequency = []; % Spot, Forward, Swap
        LTdefault = []; % allowance for long term expected default
        proportion = []; % proportion of the excess spread over swaps remaining after the deduction of LT defaults taht is due to illiquidity
        ilqpp = []; % iliq premium cut-off point
        endterm = []; % point where liqprem reduced to zero
        creditadj = []; % credit risk adjustment to swap rates to reach risk free rates
        InputlqpProp = []; %
        method = []; %
      
    end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_LiqPrem ()
           
       end
                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
        function results = bs(obj, DataSeriesIn, ParametersIn)
            
                obj.InputCorpGovSpread = DataSeriesIn(1);
                obj.InputSwapGovSpread = DataSeriesIn(2);
                
                obj.InputUS_10ySwap = DataSeriesIn(3);
                obj.InputUS_CorpCMLYield = DataSeriesIn(4);
                obj.InputUS_CMBSGovSpread = DataSeriesIn(5);
                obj.InputUS_ABSCMOGovSpread = DataSeriesIn(6);
                obj.InputUS_CorpAllocation = DataSeriesIn(7);
                obj.InputUS_CMLAllocation = DataSeriesIn(8);
                obj.InputUS_CMBSAllocation = DataSeriesIn(9);
                obj.InputUS_ABSAllocation = DataSeriesIn(10);
                
                obj.OutputFrequency=  ParametersIn{1};
                obj.OutputCompounding = ParametersIn{2};
                obj.OutputCompoundingFrequency = ParametersIn{3};
                obj.LTdefault = ParametersIn{4};
                obj.proportion = ParametersIn{5};
                obj.ilqpp = ParametersIn{6};
                obj.endterm = ParametersIn{7};
                obj.creditadj = ParametersIn{8};
                obj.method = ParametersIn{9};
                %             obj.InputlqpProp = ParametersIn{10};


           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Step 1. Derive LP before cut-off point            
                  
           for i = 1: size(obj.InputUS_10ySwap.dates, 1)        
             % derive corporate spread over swap

                % Pillar I method
                   if strcmp(obj.method, 'Pillar I')

                       % spread interpolation
                       LowerDur = obj.InputSwapGovSpread.axes(1).values (find (obj.InputSwapGovSpread.axes(1).values >= str2num(obj.InputCorpGovSpread.duration)-1, 1));
                       UpperDur = obj.InputSwapGovSpread.axes(1).values (find (obj.InputSwapGovSpread.axes(1).values >= str2num(obj.InputCorpGovSpread.duration), 1));
                       LowerSwp = obj.InputSwapGovSpread.values {i}(find (obj.InputSwapGovSpread.axes(1).values >= str2num(obj.InputCorpGovSpread.duration)-1, 1));
                       UpperSwp = obj.InputSwapGovSpread.values {i}(find (obj.InputSwapGovSpread.axes(1).values >= str2num(obj.InputCorpGovSpread.duration), 1));
                       IntSwapGovSpread(i) = LowerSwp + (UpperSwp-LowerSwp)/(UpperDur-LowerDur)*(str2num(obj.InputCorpGovSpread.duration)-LowerDur);

                       CorpSwapSpread(i) = obj.InputCorpGovSpread.values{i} - IntSwapGovSpread(i);
                   end

                % Pillar II method
                   if strcmp(obj.method, 'Pillar II');

                           % Corporate & CML exposure
                               CorpCMLSwapSpread{i} = obj.InputUS_CorpCMLYield.values{i}-obj.InputUS_10ySwap.values{i}(1); % adjust to spread over swaps
                               % interpolate AAA corporate yield
                               CorpCMLSwapSpread{i}(1) = CorpCMLSwapSpread{i}(2)*2/3;
                               US_CorpCML_SwapSpread{i} = sum((obj.InputUS_CorpAllocation.values{i}+obj.InputUS_CMLAllocation.values{i}).*CorpCMLSwapSpread{i}*100);

                           % CMBS exposure
                               US_CMBS_SwapSpread{i} = sum(obj.InputUS_CMBSAllocation.values{i}.*(obj.InputUS_CMBSGovSpread.values{i} - obj.InputUS_10ySwap.values{i}(2))); % adjust to spread over swaps

                           % ABS & CMO exposure
                               US_ABSCMO_SwapSpread{i} = sum(obj.InputUS_ABSAllocation.values{i}.*(obj.InputUS_ABSCMOGovSpread.values{i} - obj.InputUS_10ySwap.values{i}(2)));% adjust to spread over swaps

                           % Weighted average swap spread of Jackson's portfolio
                           wa{i} = US_CorpCML_SwapSpread{i} + US_CMBS_SwapSpread{i} + US_ABSCMO_SwapSpread{i};
                      
                       CorpSwapSpread(i) = wa{i};
                   end

             % derive LP (vs. swap & vs. gov)
                   LiqPrem(i) = max (0, str2num(obj.proportion).*(CorpSwapSpread(i) - str2num(obj.LTdefault))- str2num(obj.creditadj));


    
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Step 2. extrapolate LP curve
               
             % get OutPutFreqProfile
               maxTerm = str2num(obj.endterm);
               BsfrequencyprofileObject = prursg.Bootstrap.Bsfrequencyprofile(obj.OutputFrequency,maxTerm);
               OutputFrequencyProfile = BsfrequencyprofileObject.AdjustedIntervalArray;
               
             % construct LP.values
                   for j = 1:find(OutputFrequencyProfile>str2num(obj.ilqpp)-1,1);
                       LP.values{i}(j) = LiqPrem(i);
                   end
                   for j = find(OutputFrequencyProfile>str2num(obj.ilqpp),1):size(OutputFrequencyProfile,1)
                       LP.values{i}(j) = max(0, LP.values{i}(j-1) - LiqPrem(i)/(str2num(obj.endterm) - str2num(obj.ilqpp)));
                   end
           end
               
               LP.values = LP.values';
               % define other LP properties     
               LP.axes(1).title = 'term';
               LP.axes.values = OutputFrequencyProfile';
               LP.dates = obj.InputCorpGovSpread.dates;
               LP.compounding = obj.InputCorpGovSpread.compounding;
               LP.compoundingfrequency = obj.InputCorpGovSpread.compoundingfrequency;
               LP.daycount = obj.InputCorpGovSpread.daycount;          
            
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Step 3. match to the outputfrequencyprofile 
               results = BsfrequencyprofileObject.SmallerDataSeriesObject(OutputFrequencyProfile,LP);                 
               
        end
        
    end
    
    
    
end
    


