function [x,xlo,xup] = norminv(p,mu,sigma,pcov,alpha)

if nargin<1
    error('stats:norminv:TooFewInputs','Input argument P is undefined.');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters or probabilities.
sigma(sigma <= 0) = NaN;
p(p < 0 | 1 < p) = NaN;

x0 = -sqrt(2).*erfcinv(2*p);
try
    x = sigma.*x0 + mu;
catch
    error('stats:norminv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
