function [p,plo,pup] = normcdf(x,mu,sigma,pcov,alpha)

if nargin<1
    error('stats:normcdf:TooFewInputs','Input argument X is undefined.');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    z = (x-mu) ./ sigma;
catch
    error('stats:normcdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Use the complementary error function, rather than .5*(1+erf(z/sqrt(2))),
% to produce accurate near-zero results for large negative x.
p = 0.5 * erfc(-z ./ sqrt(2));
