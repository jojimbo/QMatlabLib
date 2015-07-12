function done = Prepare_for_Unit_Tests(path)

try
    if nargin == 0
        path = pwd;
    else
    end
    
    disp(['Working from path ', path]);
    disp(['Adding ', path, '/matlab_xunit_3.1/ to the matlab search path', ]);
    addpath(genpath(fullfile(path, 'matlab_xunit_3.1')))
    
    disp(['Adding ', path, '/UnitTests/ to the matlab search path', ]);
    addpath(genpath(fullfile(path, 'UnitTests')))
    
    disp(['Adding ', path, '/MasterInputFiles/ to the matlab search path', ]);
    addpath(genpath(fullfile(path, 'MasterInputFiles')))
    done = 1;
    
    
    
catch err
    done = 0;
    error(err);
end

end