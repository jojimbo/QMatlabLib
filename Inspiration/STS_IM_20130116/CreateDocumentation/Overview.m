%% Overview
% This is a top-level diagram of how miniEcapsCL Replication Portfolio is
% implemented in MATLAB.
%
% Data files for the scenarios, instruments and cashflow liabilities
% are inputs for building the replication portfolio object.
% Options for the replication are also provided as part of the configuration
% file. 
%
% Once the object is built, the actual replication is performed by means of
% an optimization. Currently only the linear optimization is implemented. 
%
% <<Overview.GIF>>
% 