function p = isdefinitepositive(a)
%% isdefinitepositive
% This function returns 1 if the matrix is definite positive and returns 0
% otherwise
%
% INPUT:
%   1. a: Matrix we want to test
%
% OUTPUT:
%   1. p: 1 if a is definite positive, 0 otherwise
%

p= 1; %true
[~,positive] = chol(a);
if positive ~= 0
    p = 0; %false
end

end