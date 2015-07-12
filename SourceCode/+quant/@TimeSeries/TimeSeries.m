%% Object class Gbm_RC_01
% Copyright 1994-2016 Riskcare Ltd.

classdef TimeSeries < timeseries
    %% TimeSeries - Wrapper around Matlab's native timeseries class
    %
    %% SYNTAX:
    %   OBJ = TimeSeries(data)
    %   OBJ = TimeSeries(data, timeunits)
    %   OBJ = TimeSeries(data, timeunits, starttime)
    %   OBJ = TimeSeries(data, 'Name', tsname)
    %   OBJ = TimeSeries(data, timeunits, starttime, 'Name', tsname)
    %
    %% DESCRIPTION:
    %   TimeSeries object that uses Matlab's native code wrapped around for
    %   easier callability and extendibility.
    %   
    %   Note this class has to be casted back into Matlab's timeseries for
    %   its use on a tscollection:
    %   timeseriescollection1 = tscollection(timeseries(TimeSeriesObject))
    %
    %% INPUTS:
    %   1. data
    %   2. timeunits
    %   3. starttime
    %
    %
    %% OPTIONAL INPUTS:
    %   1. tsname
    %   2. timevector
    %   3. 
    %
    %
    %% OUTPUTS:
    %
    %   TimeSeries model object with the following properties:
    %       Data;
    %       DataInfo;
    %       Events;
    %       IsTimeFirst;
    %       Length;
    %       Name;
    %       Time;
    %       TimeInfo;
    %       TreatNaNasMissing;
    %       UserData;
    %
    %
    %% VARIABLES:
    %   [None]
    %
        

    %% Properties
    properties
    end
    
    
    %%
    %% * * * * * * * * * * * Define TimeSeries Methods * * * * * * * * * * * 
    %%
    
    
    methods (Access = 'public')
        %% Constructor method
        function OBJ = TimeSeries(varargin)
            % Instantiate base class to maintain compatibility with tscollection
            if nargin ==0
                super_args = [];
            elseif nargin >=1
                % First input parameter is always the data used for the timeseries
                super_args = varargin{1};
            end
            OBJ = OBJ@timeseries(super_args);
            
            index = find(strcmpi(varargin, 'Name'));
            if ~isempty(index)
                OBJ.Name = varargin{index+1};
            end
            
            switch nargin
                case 1
                    % TimeSeries(data)
                    % simply use Matlab's default implementation and set
                    % time by default to:
                    %       Daily intervals
                    %       EndDate = Yesterday's Date
                    OBJ.TimeInfo.Units = 'days';
                    start = today - OBJ.TimeInfo.Length;
                    OBJ.TimeInfo.StartDate = datestr(start);
                case 2
                    % TimeSeries(data, timeunits)
                    OBJ.TimeInfo.Units = varargin{2};
                    start = today - OBJ.TimeInfo.Length;
                    OBJ.TimeInfo.StartDate = datestr(start);
                case 3
                    if index==2;
                        % TimeSeries(data, 'Name', tsname)
                        % User has provided the name but not StartDate or
                        % Units - use Defaults:
                        OBJ.TimeInfo.Units = 'days';
                        start = today - OBJ.TimeInfo.Length;
                        OBJ.TimeInfo.StartDate = datestr(start);
                    elseif isempty(index)
                        % TimeSeries(data, timeunits, starttime)
                        OBJ.TimeInfo.Units = varargin{2};
                        OBJ.TimeInfo.StartDate = varargin{3};
                    else
                        % Odd combinations of input parameters was provided
                        error('@TimeSeries:WrongInputs')
                    end
                case 4
                    error('@TimeSeries:WrongNumberOfInputs')
                case 5
                    % TimeSeries(data, timeunits, starttime, 'Name', tsname)
                    if strcmpi(varargin{4}, 'Name')
                        OBJ.TimeInfo.Units = varargin{2};
                        OBJ.TimeInfo.StartDate = varargin{3};
                        OBJ.Name = varargin{5};
                    else
                        error('@TimeSeries:WrongInputs')
                    end
                    
            end
            if strcmpi(OBJ.TimeInfo.Units, 'days')
                OBJ.TimeInfo.Format = 'dd-mmm-yyyy';
            end
            
           
            
        end
    end
    
    
    methods (Hidden)
    end
    
    
    
%% Class end
end



%% FOR TEST CASES:
%ts_RC_1 = TimeSeries(squeeze(Paths2(:,2,:)));
%ts_RC_2 = TimeSeries(squeeze(Paths2(:,1,:)), 'seconds');
%ts_RC_3 = TimeSeries(squeeze(Paths2(:,1,:)), 'seconds', '23-Apr-2011');
%ts_RC_3 = TimeSeries(squeeze(Paths2(:,1,:)), 'days', '23-Apr-2011');
%ts_RC_4 = TimeSeries(squeeze(Paths2(:,1,:)), 'Name', 'stockprices');
%ts_RC_5 = TimeSeries(squeeze(Paths2(:,1,:)), 'days', '23-Apr-2011', 'Name', 'stockprices');
