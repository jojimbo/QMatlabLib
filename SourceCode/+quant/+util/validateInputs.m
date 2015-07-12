function varargout = validateInputs(names, defaults, varargin)
%% VALIDATEINPUTS Validate parameter name/value pairs and throw errors if necessary.

%% DESCRIPTION:
%   Given the cell array of valid parameter names, a corresponding cell array of
%   parameter default values, and a variable length list of parameter name/value
%   pairs, validate the specified name/value pairs and assign values to output
%   parameters.
%
%   [P1, P2, ...] = validatePVpairs(Names, Defaults, 'Name1', Value1,
%     'Name2', Value2, ...)
%
%% INPUTS:
%   Names - Cell array of valid parameter names.
%
%   Defaults - Cell array of default values for the parameters named in Names.
%
%   'Name1', 'Name2', ... - Character strings of parameter names to be validated
%     and assigned the corresponding value that immediately follows each in the 
%     input argument list. Parameter name validation is case-insensitive and 
%     partial string matches are allowed provided no ambiguities exist
%
%   Value1, Value2, ... - The values assigned to the corresponding parameter 
%     that immediately precede each in the input argument list.
%
%% OUTPUTS:
%   P1, P2, ... - Parameters assigned the parameter values Value1, Value2, ...
%     in the same order as the names listed in Names. Parameters corresponding 
%     to entries in Names that are not specified in the name/value pairs are set
%     to the corresponding value listed in Defaults. 
%

% Copyright 1995-2010 The MathWorks, Inc.  

%
%% Initialize some variables.
%

nInputs   = length(varargin);  % # of input arguments
varargout = defaults;

% 
%% Ensure inputs represent have parameter name/value pairs.

if mod(nInputs,2) ~= 0

   error(message('validateInputs:IncorrectNumberOfInputs'));

else
%
%%  Process name/value pairs.
%
   for j=1:2:nInputs

       pName = varargin{j};

       if ~ischar(pName)
          error(message('validateInputs:NonTextString'));
       end

       i = find(strncmpi(pName, names, length(pName)));

       if isempty(i)
          error(message('validateInputs:InvalidParameter', pName)); 

       elseif length(i) > 1
%
%%        If ambiguities exist, check for exact match to narrow search.
%
         i = find(strcmpi(pName, names));

         if length(i) == 1
            varargout{i} = varargin{j+1};
         else
            error(message('validateInputs:AmbiguousParameter', pName));
         end

       else
          varargout{i} = varargin{j + 1};
       end
   end
end

