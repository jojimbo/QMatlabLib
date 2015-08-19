classdef HyperCube < handle
    %HYPERCUBE support for serialising/deserialising of a N-dimensional
    %cube according to Algo convention.(see Algo binary file format) 
    
    methods (Static)
        function series = serialise(cube, varargin)
            % cube is a N-dimensional matrix. serialise it into a vector
            % series. varargin{1} == 1 or numel(varargin) == 0, use default flatten by element
            % varargin{1} == 2, uses flatten by dimension. Default is
            % flatten by element. The two algorithms exists only for unit testing
            if(nargin > 2)
                error('invalid number of argumens');
            end
            if ~isreal(cube)
                error('hyper cube of doubles is expected not a %s', class(cube));                
            end
            option = 1;
            if(nargin == 2)
                option = varargin{1};
            end
            switch option
                case 1
                    series = flattenByElement(cube, 1, '');
                case 2
                    series = flattenByDimension(cube, 1, '');
                    
                otherwise
                    error('invalid argument for serialisation option');                    
            end            
        end
        
        function series = serialise2d(matrix)
            series = [];
            for i = 1:size(matrix, 1);
                series = [ series matrix(i, :) ];
            end
        end
        
        function outCube = deserialise(axes, series)
            % assemble the outCube, according to the dimensions of inCube,
            % from the contents of the vector series
            inCube = prursg.Engine.HyperCube.makeCubeOfZeros(axes);
            outCube = assemble(inCube, series, 1, '', 1);
        end
        
        function outCube = deserialiseInCube(inCube, series)
            % assemble the outCube, according to the dimensions of inCube,
            % from the contents of the vector series
            outCube = assemble(inCube, series, 1, '', 1);
        end
                
        function element = getElement(hyperCube, coordinates)
            %
            % hyperCube is a n-dimensional matrix. The address of an element in this
            % matrix is given by the coordinates vector. The coordinates
            % are converted into string for subscript addressing. Must be a
            % more elegant way to do this?
            %
            element = eval(['hyperCube(' makeSubscript(coordinates) ');']);
        end        
        
        function hyperCube = setElement(hyperCube, coordinates, value)            
            switch numel(coordinates)
                case 1
                    hyperCube(coordinates) = value;
                case 2
                    hyperCube(coordinates(1), coordinates(2)) = value;
                case 3
                    hyperCube(coordinates(1), coordinates(2), coordinates(3)) = value;                    
                otherwise
                    eval(['hyperCube(' makeSubscript(coordinates) ') = value;']);
            end            
            %eval(['hyperCube(' makeSubscript(coordinates) ') = value;']);
        end
                
        function nAxis = getNumberOfAxis(hyperCube)
            if isscalar(hyperCube)
                nAxis = 0;
            else
                if isvector(hyperCube)
                    nAxis = 1;
                
                else
                    nAxis = ndims(hyperCube);
                end
            end
        end
                
        function cube = makeCubeOfZeros(axes)
            % returns a zeroed HyperCube described by the vector of axis
            nDims = numel(axes);
            if nDims == 0
                cube = 0; %scalar value
            else
                dims = zeros(1, nDims);
                for i = 1:nDims
                    dims(i) = numel(axes(i).values);
                end
                if(nDims == 1)
                    % the first dimension is by row!
                    cube = zeros(dims(1), 1); % otherwise zeros(dims(1)) will reserve 2d matrix
                else
                    cube = zeros(dims);
                end            
            end
        end
        
    end
    
end

% private functions
function out = flattenByDimension(v, dim, coords)
    out = [];
    if dim == ndims(v)
        value = eval(['v(' append(coords, ':') ');']);
        out = [ out reshape(value, 1, numel(value)) ]; % without reshape - no juju
    else
        for i = 1:size(v, dim) % last dimension reached
            subscript = append(coords, i);
            out = [ out flattenByDimension(v, dim + 1, subscript)]; %#ok<AGROW>
        end
    end
end

function [out index] = assemble(v, flatty, dim, coords, flatIndex)
    for i = 1:size(v, dim)
        subscript = append(coords, i);
        if dim == ndims(v) % last dimension reached 
            value = flatty(flatIndex);  %#ok<NASGU>
            flatIndex = flatIndex + 1;
            str = ['v(' subscript ') =  value;'];
            eval(str);
        else
            [v, flatIndex] = assemble(v, flatty, dim + 1, subscript, flatIndex);
        end        
    end
    out = v; % matlab passes by value
    index = flatIndex;
end

function out = flattenByElement(v, dim, coords)
    out = [];
    for i = 1:size(v, dim)
        subscript = append(coords, i);
        if dim == ndims(v) % last dimension reached                        
            value = eval(['v(' subscript ');']);
            out = [ out value ]; %#ok<AGROW>
        else
            out = [ out flattenByElement(v, dim + 1, subscript)]; %#ok<AGROW>
        end        
    end
end

function subscript = append(coords, i)
    if(isempty(coords))
        subscript = num2str(i);
    else
        subscript = [ coords ', ' num2str(i) ];
    end
end


function subscript = makeSubscript(coordinates)
    subscript = num2str(coordinates, '%d,');
    subscript = subscript(1:end - 1); % remove trailing ','            
end

