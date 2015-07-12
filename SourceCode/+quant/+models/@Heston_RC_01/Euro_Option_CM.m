%% Function Euro_Option_CM for Heston_RC_01 model
% Copyright 1994-2016 Riskcare Ltd.

function [Ks C] = Euro_Option_CM(OBJ, EUR1, S0, v0, ValuationDate)

%% HESTON Closed Form solution for Euro_Options using Carr Madan formula
% Returns prices for a grid of Strikes

% Hardcoded for now:
numberDaysInYear = 365;

T = datenum(EUR1.MaturityDate) - datenum(ValuationDate);
T= T/numberDaysInYear;


eta1 = 0.25;
N = 4096;
alpha = 1.5;
lambda = 2.*pi./(N.*eta1);
b = lambda.*N./2;

%grid for Simpson's rule:
v = eta1.*(0:(N-1));
ks = -b + lambda.*((1:N)-1);

Ks = exp(ks); %the strikes grid
C = zeros(1, length(ks));
phi = zeros(1, N);
ji = zeros(1, N);
vector = zeros(1, N);
delta = zeros(1, N);
delta(1) = 1;
switch EUR1.OptionType
    case {'Call','CALL'}
        for j=1:N
            phi(j) = OBJ.phi_Heston(T, S0, v0, (v(j)-(alpha+1).*1i) );
            ji(j) = exp(-OBJ.drift.*T).*phi(j);
            ji(j) = ji(j)./(alpha.*alpha + alpha - v(j).*v(j) + 1i.*(2.*alpha +1).*v(j));
            %for Simpson's rule:
            vector(j) = exp(1i.*v(j).*b).*ji(j).*eta1.*(3+(-1).^j-delta(j))./3;
        end
        Sum = fft(vector);
        C = real(Sum).*exp(-alpha.*ks)./pi;
        
    case {'Put','PUT'}
        error('Not yet implemented');
        
end
end
