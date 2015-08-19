function TestBootstrap()
    % Test function for bootstrapping engine
    clear;
    clc;
    import prursg.HistoricalDAO.*;
    DAO = HistoricalDAO('marketData');
    dataObjIn = DAO.populateData('TEST_NYC','31/01/2009','31/12/2009');
    dataObjOut = Bootstrap(dataObjIn,'BsNyc');
end

function DataSeriesOut = Bootstrap(DataSeriesIn,bootstrapper)
    % Inputs:
    % DataSeriesIn - data to be bootstrapped in the form of a DataSeries
    % object
    % bootstrapper - string equal to name of the boostrapping algorithm

    % instantiate a boostrapping engine
    BootstrapEngine = prursg.Bootstrap.BootstrapEngine();
    
    % set the desired bootstrapping algorithm
    eval(['BootstrapEngine.set_method(prursg.Bootstrap.' bootstrapper '())']);
    
    % apply bootstrapping algorithm to a DataSeries object and return a DataSeries
    % object
    DataSeriesOut = BootstrapEngine.bootstrap(DataSeriesIn);
end