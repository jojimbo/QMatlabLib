function [curves, factory] = curves()
%% curves
% This helper function is a thin wrapper around the curve factory list
% method.
%
% INPUT:
%   1. None
%
% OUTPUT:
%   1. curves: a list of available curves
%
    factory = engine.factories.CurveFactory(); 
    curves = factory.list();
end