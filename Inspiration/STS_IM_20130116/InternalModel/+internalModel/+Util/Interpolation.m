%% Interpolation
% This function interpolates linearly for 1 and 2 dimmensional data sets
% When the points to be interpolated fall outside of the available range on
% the data set, flat extrapolation is performed.
%
% INPUTS:
%   1. targets: provided in cell format
%   2. data: provided in numeric array format
%   3. axes: provided in cell format
%   4. interpmethod (OPTIONAL)
%
% OUTPUTS:
%   1. intvalues: numeric array with ONLY the interpolated values (axes
%   determined by targets input)
%   2. targets: returns the input targets cell array
%

function [intvalues, targets] = Interpolation(targets, data, axes, interpmethod)
if (nargin < 4)
    interpmethod = 'linear';
    %%warning('STS_CM:MissingInterpConfg', 'Using linear interpolation method by default');
    disp('Info: Using linear interpolation method by default');
end

if length(axes) == 1
    axis = axes{1};
    % For 1D case supports cell and array input format for targets,
    % though cell should be the preferred mode (for consistency with 2D and
    % higher cases
    if iscell(targets)
        targets1 = targets{1};
    elseif isnumeric(targets)
        targets1 = targets;
    else
        error('STS:InterpolationInputs', '1D interpolation with targets in not supported format (must be cell or array)')
    end
    %Check that both are columns
    if isrow(targets1)&& ~isscalar(targets1); targets1 = targets1'; end
    if isrow(axis)&& ~isscalar(axis); axis = axis'; end
    
    intvalues = interp1(axis, data, targets1, interpmethod, NaN);
    % Flat extrapolation outside of the range defined by the axis
    if (any(targets1>axis(end)~=0)); intvalues(targets1>axis(end),:) = repmat(data(end,:), sum(targets1>axis(end)), 1); end
    if (any(targets1<axis(1)~=0)); intvalues(targets1<axis(1),:) = repmat(data(1,:), sum(targets1<axis(1)), 1); end
    % Check for NaNs
    if sum(isnan(intvalues)) >0
        warning('STS:MissingInterpPoints', 'Some points were not interpolated and have NaN values!');
    end

elseif length(axes) == 2
    axis1 = axes{1};
    axis2 = axes{2};
    targets1 = targets{1};
    targets2 = targets{2};
    % TO DO  - CHECK size(data)= (length(axis1), length(axis2)) -- TO BE
    % SPARED if we move to DataSeries objects
    axis1extended = unique(sort(cat(1, axis1, targets1)));
    axis2extended = unique(sort(cat(1, axis2, targets2)));
    % Interpolate accross the rows (we get values for all the values in
    % axes2extended, so the number os columns increases
    %Check that all are columns
    if isrow(targets1)&& ~isscalar(targets1); targets1 = targets1'; end
    if isrow(axis1)&& ~isscalar(axis1); axis1 = axis1'; end
    if isrow(axis1extended)&& ~isscalar(axis1extended); axis1extended = axis1extended'; end
    if isrow(targets2)&& ~isscalar(targets2); targets2 = targets2'; end
    if isrow(axis2)&& ~isscalar(axis2); axis2 = axis2'; end
    if isrow(axis2extended)&& ~isscalar(axis2extended); axis2extended = axis2extended'; end

    if numel(axis2)==1
        intvalues1 = data; % This is actually 1D interpolation
    else
        C = num2cell(data, 2);
        fhandle = @(x) interp1(axis2, C{x}, axis2extended , interpmethod, NaN);
        intvalues1 = zeros(numel(axis1),numel(axis2extended));
        for i=1:numel(axis1)
            intvalues1(i,:) = fhandle(i);
            intvalues1(i, axis2extended>axis2(end)) = data(i,end);
            intvalues1(i, axis2extended<axis2(1)) = data(i,1);
        end
    end
    
    % Now interpolate accross columns to increase the number of rows
    if numel(axis1)==1
        intvalues2 = intvalues1; % This is actually 1D interpolation
    else
        intvalues1 = repmat(intvalues1, 1, numel(axis2extended));
        C = num2cell(intvalues1, 1);
        fhandle = @(x) interp1(axis1, C{x}, axis1extended , interpmethod, NaN);
        intvalues2 = zeros(numel(axis1extended),numel(axis2extended));
        for i=1:numel(axis2extended)
            intvalues2(:,i) = fhandle(i);
            intvalues2(axis1extended>axis1(end), i) = intvalues1(end, i);
            intvalues2(axis1extended<axis1(1), i) = intvalues1(1, i);
        end
    end
    
    % We only keep the target points
    intvalues3 = zeros(numel(targets1),numel(axis2extended));
    for i = 1:numel(targets1)
        intvalues3(i,:) = intvalues2(axis1extended==targets1(i),:);
    end
    intvalues = zeros(numel(targets1),numel(targets2));
    for i = 1:numel(targets2)
        intvalues(:,i) = intvalues3(:, axis2extended==targets2(i));
    end
    
    if sum(isnan(intvalues)) >0
        warning('STS:MissingInterpPoints', 'Some points were not interpolated and have NaN values!');
    end

else
    error('STS:Interpolation', 'Interpolation method with order greater than 3 not implemented yet')
end

    
end