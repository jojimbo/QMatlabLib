%% GAUSSIAN
% *PruRSG Engine Dependency Model  - Gaussian Copula Dependency Model
% 
% *The Gaussian class returns an array of rank correlated standard normal variates given an array of 
% uncorrelated normal variates and a correlation matrix.
%
%

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Gaussian < prursg.Engine.DependencyModel
    %PRURSG.GAUSSIANCOPULA Implements the Gaussian Copula for risk
    %correlation
    %
    
    %   Copyright 2010 The MathWorks, Inc
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[L]|* - Lower Triangle factor $L$ of the covariance matrix, $C$, such
% that $LL'=C$
%
    properties
        L % Factor of covariance matrix C, C = L*L'.  Lower-triangular.
    end

%% List of Methods
% This model class has the following methods:
%
% *|1) [buildCorrMat()]|* - Decompose input correlation matrix, $C$ into Cholesky factors, $L$ to
% produce correlated random number streams.
%
% The function takes a correlation Matrix as _corrMat_, and attempts to
% find the Lower Cholesky Matrix, $L$, using the chol() function. If the
% function fails (because the matrix is not Positive Semi Definite (PSD)) then a warning is sent to the terminal. 
%
% The method then first adjusts the matrix to the nearest (measured by the Frobenious Norm of the distance) PSD matrix
% using the algorithm described in Nicholas J. Higham, 2002,
% "Computing the Nearest Correlation Matrix - A Problem from Finance"
% http://eprints.ma.man.ac.uk/232/01/covered/MIMS_ep2006_70.pdf
% 
% Should the chol() function still fail to find a solution, then the
% alternative cholesky() function is used, which is tolerant to a nod-PSD
% matrix, but may return a complex solution. The real part of the returned
% complex solution is returned as the lower triangle, _L_. In this case a
% warning is returned to the terminal that an approximate cholesky
% decomposition is being applied.
%
% *|2) [correlate()]|* - generates the rank correlated variates, $X$, from the uncorrelated variates, $Z$, using
% the matrix multiplication  $Z = XL'$, where $L$ is the lower triangle
% cholesky matrix.
%
% This produces a series of correlated variates as weighted sums of the
% uncorrelated variates which when their correlation is measured, gives the
% desired correlation $C=LL'$.
%



    methods
        function obj = Gaussian()
            obj = obj@prursg.Engine.DependencyModel();
            obj.L = [];
        end
        
        function buildCorrMat( obj , corrMat)
            % DependenciesEngine.buildCorrMat - build correlation matrix
            %   obj.buildCorrMat( corrMat, riskNames)
            % Decompose input correlation matrix into Cholesky factors to
            % produce correlated random number streams.
            % Inputs:
            %   corrMat - correlation matrix
            %   riskNames - cell array of strings of risk names
            %   corresponding to the columns and rows of corrMat
            % Outputs:
            %   None.
            try
                obj.L = corrMat;
                obj.L = chol(obj.L,'lower');
            catch %#ok<CTCH>
                fprintf('GaussianCopula - applying correction to correlation matrix \n');
                obj.L = adjustCorr(obj.L);
                L = validcorr(obj.L,100);
                try
                    L = chol(L,'lower');
                catch
                    fprintf('GaussianCopula - Warning: approximate Cholesky factorisation used \n');
                    L = real(cholesky(L));
                end
                obj.L = L;
            end
            fprintf('GaussianCopula - cholesky decomposition complete \n');
        end
        
        function corrNumbers = correlate(obj, uncorrNumbers)
            corrNumbers = uncorrNumbers* obj.L';
            
        end
    end
end
function matOut = adjustCorr(matIn)
% handle rounding error of using Higham's algorithm - set all 99%
% correlation to 98
    for i1 = 1:size(matIn,1)
        for i2 = 1:size(matIn,2)
            if matIn(i1,i2) == 0.99
                matIn(i1,i2) = 0.98;
            end
        end
    end
    matOut = matIn;
end

function C=validcorr(A,m)
%Based on Nicholas J. Higham, 2002,
%"Computing the Nearest Correlation Matrix - A Problem from Finance"
%http://eprints.ma.man.ac.uk/232/01/covered/MIMS_ep2006_70.pdf
S=zeros(size(A));
Y=A;
%m = 100;
for k=1:length(A)*m
    R=Y-S;
    X=Ps(R);
    S=X-R;
    Y=Pu(X);
    % fprintf('%d %g\n',k,norm(Y-X));
    try
        chol(Y);
        C=Pu(X);
        break
    catch %#ok<CTCH>
    end
    % added to allow alogrithm to converge if size of negative eigenvalues
    % are within tolerance, this appears to be only needed in single CPU
    % environment (lldmat01v)
    if k > 20
        if isreal(eig(Y))
            if min(eig(Y)) >= -0.00001
                disp(['GaussianCopula - corr mat not PD and still contains small negaive eigenvalues']);
                Y = correctCorr(Y);
                C=Y;
                break
            end
        end
    end
end
    function X=Ps(A)
        [Q D]=eig(A);
        Q = real(Q);
        D = real(D);
        X=Q*max(D,0)*Q';
    end

    function Y=Pu(X)
        Y=X-diag(diag(X))+eye(length(X));
    end
%C=Pu(X);
end

function out = correctCorr(Y)
    % force correction of corr mat to PD
    [vec val ] = eig(Y);
    for ii = 1:size(val,1)
        if ~isreal(val(ii,ii))
            val(ii,ii) = 0;
        end
        if val(ii,ii)<0
            val(ii,ii) = 0;
        end
    end
    out = real(vec*val*inv(vec));
end

function outMat = cholesky(x)
    % direct routine for computing the Cholesky decomposition
    n = 0;
    k = 0;
    j = 0;
    n = size(x,1);
    tempMat = zeros(n,n);
    for j = 1:n
        for k = 1:n
            tempMat(j,k) = 0;
        end
    end
    for k = 1:n
        if x(k,k) <= 0
            x(k,k) = x(k,k);
        end
        x(k,k) = x(k,k)^(0.5);
        k2 = 0;
        for k2 = k + 1:n
            x(k2,k) = x(k2,k)/x(k,k);
        end
        for j = k+1:n
            for k2 = j:n
                x(k2,j) = x(k2,j) - x(k2,k)*x(j,k);
            end
        end
    end
    for j = 1:n
        for k2 = j:n
            tempMat(k2,j) = x(k2,j);
        end
    end
    outMat = tempMat;
end




