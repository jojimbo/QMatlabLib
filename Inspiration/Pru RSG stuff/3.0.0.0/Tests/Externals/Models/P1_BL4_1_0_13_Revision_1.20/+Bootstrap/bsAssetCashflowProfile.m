classdef bsAssetCashflowProfile < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description :: Created by Graeme Lawson on the 06/10/11
    % For a given set of  asset prices or rates, this function
    % return am asset price and it's associated profile of cashflow amounts
    % and cashflow values
    % NB The function allows the user to specify a mixture of different
    % rate or asset types
        
    properties
       dblMaturityTolerance  = 1/52;  
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = bsAssetCashflowProfile ()
        
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % methods and functions
        
        function [ dblAssetPrices,dblCashflowMaturities, dblCashflows] = assetcashflowprofiles(obj,dblRawAssetValuesOrRates, dblRawMaturities, .... 
                                                                                 sRateTypes ,compounding, compoundingfrequency,units) 
                               
               iNumberofAssetPrices =size(dblRawAssetValuesOrRates, 1) ;  
               dblAssetPrices =zeros(iNumberofAssetPrices, 1) ;             
                          
               dblCashflows = cell(iNumberofAssetPrices ,1)  ; % Create a cell array of cashflows profiles for each asset
               dblCashflowMaturities = cell(iNumberofAssetPrices ,1)  ; % Create a cell array of cashflow matrurity profiles for each asset               
                            
               
               for i = 1 : iNumberofAssetPrices                   
                   
                    % Adjust data into absoulte amount/values
                   if strcmp(units(i, :), 'percent')
                       dblRawAssetValuesOrRates(i,1) = (dblRawAssetValuesOrRates(i,1)./ 100);
                   else
                     
                   end    
                                      
                   if strcmp(lower(sRateTypes(i, :)), 'zcb')
                       % This is the most straightforward case
                       dblAssetPrices(i,1) = dblRawAssetValuesOrRates(i,1);
                       % Cashflow timings
                       dblCashflowMaturities{i ,1} = dblRawMaturities(i,1);
                       % Cashflow amounts
                       dblCashflows{i ,1} = 1 ;
                       
                   elseif strcmp(lower(sRateTypes(i, :)), 'spot')
                       
                       % Cashflow timings
                       dblCashflowMaturities{i ,1} = dblRawMaturities(i,1);
                       % Cashflow amounts
                       dblCashflows{i ,1} = 1 ;
                       
                       
                       if strcmp(compounding(i, :), 'ann')
                           dblAssetPrices(i,1) = ( 1 + dblRawAssetValuesOrRates(i,1)/compoundingfrequency(i,1)) ^ (- compoundingfrequency(i,1)* dblRawMaturities(i,1));
                       elseif strcmp(compounding(i, :), 'cont')
                           dblAssetPrices(i,1) = exp(- dblRawAssetValuesOrRates(i,1)* dblRawMaturities(i,1));
                       end
                       
                   elseif strcmp(lower(sRateTypes(i, :)), 'swap') || strcmp(lower(sRateTypes(i, :)), 'par')
                       
                        dblAssetPrices(i,1) = 1; % Swap Rates are assumed to be the par rates of the market discount curve :: Therefore NPV of fixed leg is equal to 1        
                       
                        % Count the number of cashflows 
                       remainder = mod(dblRawMaturities(i,1), (1/compoundingfrequency(i,1)));
                       %remainder = mod(str2double(dblRawMaturities{i,1}), (1/compoundingfrequency(i,1)));
                       dblCashflowMaturities{i ,1} = (1/compoundingfrequency(i,1):1/compoundingfrequency(i,1):dblRawMaturities(i,1));
                       %dblCashflowMaturities{i ,1} = (1/compoundingfrequency(i,1):1/compoundingfrequency(i,1):str2double(dblRawMaturities(i,1)));
                      
                       if remainder < obj.dblMaturityTolerance 
                           dblRawMaturities(i,1)= dblRawMaturities(i,1) - remainder ;
                           %dblRawMaturities{i,1}= str2double(dblRawMaturities{i,1}) - remainder;
                           iNumberofCashflows  = compoundingfrequency(i,1)*dblRawMaturities(i,1) ;  
                           %iNumberofCashflows  = compoundingfrequency(i,1)*dblRawMaturities{i,1};
                       else
                           iNumberofCashflows  = floor(compoundingfrequency(i,1)*dblRawMaturities(i,1))+1 ;
                           %iNumberofCashflows  = floor(compoundingfrequency(i,1)*dblRawMaturities{i,1})+1;
                           dblCashflowMaturities{i ,1} =[dblCashflowMaturities{i ,1}  dblRawMaturities(i,1)] ;
                           %dblCashflowMaturities{i,1} =[dblCashflowMaturities{i ,1}  dblRawMaturities{i,1}];
                       end
                            
                         iNumberofCashflows  = round(iNumberofCashflows );
                       
                       % Cashflow amounts
                       dblCashflowTemp = (dblRawAssetValuesOrRates(i,1)./compoundingfrequency(i,1)).*ones(1,iNumberofCashflows);
                       dblCashflowTemp( 1, iNumberofCashflows) = dblCashflowTemp( 1, iNumberofCashflows) +1 ;
                       dblCashflows{i ,1} = dblCashflowTemp ; % Create Cell Array of cashflow values                       
                       
                   end
                   
               end
    
        end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % End of methods
    end
end

