classdef OpFreqSev < prursg.Engine.Model    

    properties
        % model parameters
        sigma = [];
        mu = [];
        r = [];
        p = [];
        s = [];
    end
        
    methods
        function obj = OpFreqSev()
            % Constructor
            obj = obj@prursg.Engine.Model('OpFreqSev');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            
            %Objetive function for severity fitting
            function solve1 = sevfunc(x)
                mu = log(calibParamTargets{1});               
                solve1 = (calibParamTargets{2}-exp(mu+x*norminv(str2num(calibParamNames{2}),0,1)))^2;
            end
            
            %Objetive function for freq fitting
            function solve2 = freqfunc(p)
                L = [0:2999]';
                I = ones(1,3000)';
                C = I - nbincdf(L,obj.r,p);
                ActualPertcentile = C(calibParamTargets{4});
                solve2 = 100*(1-str2num(calibParamNames{4})-ActualPertcentile);
            end
            
            %fit severity
            x0 = 1; %start sigma at 1
            
            %minimize sum of square differences - constraint sigma>0
            x = fmincon(@sevfunc,x0,[],[],[],[],0,10);
            
            obj.sigma = x; 
            obj.mu=log(calibParamTargets{1});
            
            %fit freq
            if calibParamTargets{3}==0 && calibParamTargets{4}==1 ; %if mode is 0 extreme 1
                r = 1;
                obj.r = r;
                p = str2num(calibParamNames{4});
            else
                
                %possible to fit?
                for r = 1:99
                    L = [0:2999]';
                    I = ones(1,3000)';
                    F0 = I - nbincdf(L,r,max(0.00001,(r-1)/(calibParamTargets{3}+r)));
                    F1 = I - nbincdf(L,r,min(1,(r-1)/(calibParamTargets{3}+r-1)));
                    
                    UpperBound = F0(calibParamTargets{4});
                    LowerBound = F1(calibParamTargets{4});
                    if LowerBound < 1-str2num(calibParamNames{4}) && 1-str2num(calibParamNames{4}) < UpperBound || r==99;
                        break
                    elseif UpperBound<1-str2num(calibParamNames{4}) 
                        r=r-1;
                        break
                    end
                end
                
                obj.r = r;
                  if  r == 99 || UpperBound<1-str2num(calibParamNames{4}) 
                      LB = 0.00001;
                      UB = 0.99999;
                  else
                    LB = max(0.00001,(r-1)/(calibParamTargets{3}+r));
                    UB = min(1,(r-1)/(calibParamTargets{3}+r-1));
                  end 
                
                %fitting using different constraints                
                p0 = [LB,UB];
                p = fzero(@freqfunc,p0);

            end    
           
            obj.p = 1 - p;
            
            %random seed
            s = calibParamTargets{5};
            obj.s = s;
                        
            success_flag = 1;
        end
        
        
    
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        %simulation
        function series = simulate(obj, workerObj, corrNumElements)  
            freq = nbininv(normcdf(corrNumElements),obj.r,1-obj.p);
            rows = length(corrNumElements);
            columns = max(max(freq),1);
            if mod(columns,2)~=0
                columns = columns + 1;
            end

            %if obj.s>0
               stream=RandStream('mt19937ar','Seed',obj.s);
               RandStream.setDefaultStream(stream)  
            %end
            
            rn = rand(rows,columns);
            rn(:,2:2:columns) = 1 - rn(:,1:2:columns-1);
            
            for i = 1:rows
                rn(i,freq(i)+1:columns) = 0;                
            end
            
            sev = logninv(rn, obj.mu, obj.sigma); 
            
            if obj.mu==0 && obj.sigma==0
              series=zeros(rows,1);
            elseif columns>1 
              series=sum(sev')';  
            else
              series=sev; 
            end
            
        end
       
        
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

