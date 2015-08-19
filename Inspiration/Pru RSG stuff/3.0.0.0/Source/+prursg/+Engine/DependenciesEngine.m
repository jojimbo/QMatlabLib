classdef DependenciesEngine < prursg.Engine.Engine

    properties
        %seed % Array of seeds.  <0 means no seed
    end
    
    properties ( SetAccess = private )
        %randstream % Cell array of random streams per risk
        dependencyModel
        rngs; %cell arrray of RandomNumberGenerators per risk
    end
    
    methods
        %BE CAREFUL, THE SIGNATURE OF THIS FUNCTION HAS CHANGED! BEFORE: function obj = DependenciesEngine(dependencyModel, seeds)
        function obj = DependenciesEngine(dependencyModel, randomnumbergenerators)
            obj = obj@prursg.Engine.Engine();
            %obj.randstream = {};
            %obj.seed = [];
            obj.dependencyModel = dependencyModel;
            obj.rngs = randomnumbergenerators;
            %obj.seed = seeds;
        end
        
        function addRisk(obj , risks)
            
            % Add the risks to the engine
            obj.addRisk@prursg.Engine.Engine(risks);
            % Add storage for the new random number streams
            
            rs = cell(numel(risks),1); % each risk has a rngs, even if its model needs several StochasticInputs
            %obj.randstream = [obj.randstream; rs];
            obj.rngs = [obj.rngs; rs];
        end
        
        function ind = removeRisk( obj , riskName )                        
            ind = obj.removeRisk@prursg.Engine(riskName);
            %obj.seed( ind ) = [];
            %obj.randstream( ind ) = [];
            obj.rngs(ind) = [];
        end
        
        function buildCorrMat( obj , corrMat)
            obj.dependencyModel.setRisks(obj.risks);
            obj.dependencyModel.buildCorrMat(corrMat);
        end
        
        function output = generateCorrelatedNumbers(obj, risks, numSimulations)
            disp([datestr(now) ' Random number generation started.']);
            t = tic();
                        
            inputCountMatrix = zeros(1, numel(risks));            
            totalCounts = 0;
            for i = 1:numel(risks)
                inputCountMatrix(1, i) = risks(i).model.getNumberOfStochasticInputs();
                totalCounts = totalCounts + inputCountMatrix(1, i);
            end
            
            startColIndex = 1;
            endColIndex = 0;
            output = zeros(numSimulations, totalCounts);
            for i = 1:numel(risks)
                nInputs = inputCountMatrix(1, i);                
                if(nInputs > 0)                
                    numbers = zeros(numSimulations,nInputs);                    
                    %rstream = obj.randstream{i}; % set into temp variable for speed
                    rng = obj.rngs{i}; % set into temp variable for speed
                    
                    %for j = 1:numSimulations
                    %    for k = 1:nInputs
                    %        numbers(j,k) = rand(rstream);
                    %    end
                    %end
                    
                    %numbers = rand(rstream, nInputs, numSimulations);
                    numbers = rng.Rand(numSimulations, nInputs); % We are drawing the numbers uniformly distributed
                    %numbers = numbers';                    
                    numbers = norminv(numbers, 0, 1);

                    endColIndex = startColIndex + nInputs -1;                
                    output(:, startColIndex:endColIndex) = numbers;
                    startColIndex = endColIndex + 1;
                end
                
            end
            % correlate numbers
            output = obj.dependencyModel.correlate(output); % We correlate the numbers using the dependencyModel
            toc(t);
            disp([datestr(now) ' Random number generation completed']);
        end
        
        
        function saveCorrelatedNumbers(obj, ns, numSims, batchIndex, nBatches)
            % DependenciesEngine.saveCorrelatedNumbers - save correlated random numbers
            %   obj.saveCorrelatedNumbers(ns, numSims, batchIndex)
            % Serializes correlated random numbers for subsequent deserialization
            % Inputs:
            %   ns - number of samples
            %   numSims - number of simulations
            %   batchIndex - index of batch to save
            %   nBatches - number of batches to be used
            % Outputs:
            %   None
            bucket = prursg.Engine.DependenciesEngine.getBucket(numSims, nBatches);
            nSamples = max(ns);
            iDone = 0;
            iLoop = 0;
            while iDone<numSims
                iLoop = iLoop + 1;
                siz(iLoop) = iDone; %#ok<AGROW>
                iDone = iDone + bucket;
            end
            nRisks = numel(obj.risks);
            %rndstr = obj.randstream;
            rngenerators = obj.rngs;
            correlate = @(x) obj.dependencyModel.correlate(x);
            for iLoop=1:numel(siz)
            %for iLoop=1:numel(siz)
                iDone = siz(iLoop);
                %iLoop = iLoop + 1;
                nums = cell(nSamples,1);
                rn = cell(nRisks,1);
                for risk=1:nRisks
			%%SHAUN CHANGE 27JAN11
                    %rn{risk} = norminv(rand(rndstr{risk},bucket,nSamples),0,1);
                    randoms = rngenerators{risk}.Rand(bucket, nSamples);
                    rn{risk} = norminv(randoms,0,1);
			%%END CHANGE
                end

                for i=1:nSamples
                    numsi = [];
                    for j=1:nRisks
                        numsi = [numsi,rn{j}(:,i)]; %#ok<AGROW>
                    end
                    nums{i} = correlate(numsi);
                end
                for i=1:nRisks
                    xxx = zeros(bucket,ns(i));
                    for j=1:ns(i)
                        xxx(:,j) = nums{j}(:,i);
                    end
                    try
                        mkdir('temp');
                    catch e
                        error('DependenciesEngine:DirCreation',...
                            'Can not create temp folder,error is %s',e.message);
                    end
                    fname = fullfile( 'temp', sprintf( 'XXX_R%d_S%d_B%d', i, iDone+1, batchIndex ) );
                    mySave(fname,xxx);
                end
            end
            

        end
        
        function setRandomBehaviour(obj)
            % DependenciesEngine.setRandomBehaviour - set stream behaviour
            %   obj.setRandomBehaviour()
            % Sets the seeds for the random streams to the corresponding
            % value in the seed property of the DependenciesEngine or a
            % random value depending on current clock value if unset.
            % Inputs:
            %   None
            % Outputs:
            %   None
            
            for i=1:numel(obj.risks)
                obj.rngs{i}.Initiate();
                %if obj.seed(i)>0
                %    obj.randstream{i} = RandStream.create('mt19937ar','seed',obj.seed(i));
                %else
                %    obj.randstream{i} = RandStream.create('mt19937ar','seed',sum(100*clock)+i);
                %end
            end
        end
    end
    
    methods ( Static )
        function bucket = getBucket( numSims , nBatches )
            
            % This value determines the maximum bucket size, it could be
            % tuned. The higher the value, the less number of files it will
            % generate, but it will use more memory. The value of 1000
            % seemed reasonable (but it has not been tuned by using a large
            % number of simulations).
            maxBucketSize = 1000;
            
            bucketSize = min(maxBucketSize,floor(numSims/nBatches));
            if numSims<bucketSize
                bucket = numSims;
            else
                bucket = bucketSize;
            end
        end
    end
    
end

function mySave(fname,xxx) %#ok<INUSD>
    save(fname,'xxx', prursg.Util.FileUtil.GetMatFileFormat());
end
