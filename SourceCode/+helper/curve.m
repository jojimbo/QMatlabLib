function [curve, factory] = curve(name, varargin)
%% curve
% This helper function is a thin wrapper around the curve factory get
% method.
%
% INPUT:
%   1. name: the name of the curve
%   2. varargin: optional argumnets that will be passed to the curves
%   constructor
%
% OUTPUT:
%   1. curve: a curve instance
%
    factory = engine.factories.CurveFactory(); 
    curve = factory.get(name, varargin{:});
end