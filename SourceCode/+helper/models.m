function [models, factory] = models()
%% curves
% This helper function is a thin wrapper around the model factory list
% method.
%
% INPUT:
%   1. None
%
% OUTPUT:
%   1. models: a list of available curves
%
    factory = engine.factories.ModelFactory(); 
    models = factory.list();
end