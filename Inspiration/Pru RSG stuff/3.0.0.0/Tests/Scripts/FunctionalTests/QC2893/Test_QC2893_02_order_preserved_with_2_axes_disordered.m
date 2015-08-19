%% Test_QC2893_02_order_preserved_with_2_axes_disordered
%
% SUMMARY: This tests ensures that order of the axes is preserved when and
% DSO is stored in the database and then retrieved from the database into
% another DSO and the axes values are not in any numeric order.
%
%%

function Test_QC2893_02_order_preserved_with_2_axes_disordered()
disp('Starting: Test_QC2893_01_order_preserved_with_2_axes()...')

% Set default paths
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
addpath(regexprep(pathstr,'Tests.+$','Source'));
import prusg.*

% START OF TEST
    % input data series
    dataSeriesName = 'testcase3_axes_disordered';
    fromDate = '30/Dec/2011';
    toDate ='30/Dec/2011';
    % Set file paths
    inputDir = strcat(pathstr, filesep,'BootstrapInput');
    outputDir = strcat(pathstr, filesep,'BootstrapOutput');

    inDataSeries = xmlToDataSeries(dataSeriesName, inputDir, outputDir, fromDate, toDate);
    inDataSeries.Status = 1;
    inDataSeries.Purpose = 'Hey';
    dataSeriesToMDS(inDataSeries);
    outDataSeries = mdsToDataSeries(dataSeriesName, fromDate, toDate);
    
    assert(inDataSeries.eq(outDataSeries),...
        'NOT SUCCESSFUL: In inDataSeries.Name: %s Out outDataSeries: %s differ',...
        inDataSeries.Name, outDataSeries);    
    
    % save data series to file
    dataSeriesToXML(outDataSeries, inputDir, outputDir);

disp('Test_QC2893_02_order_preserved_with_2_axes_disordered() COMPLETE.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dataSeries = xmlToDataSeries(dataSeriesName, inputDir, outputDir, fromDate, toDate)
xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
xmlDao.InputDir = inputDir;
xmlDao.OutputDir = outputDir;
dataSeries = xmlDao.PopulateDataSeriesContent(dataSeriesName, fromDate, toDate, fromDate, '', '');
end

function dataSeries = mdsToDataSeries(dataSeriesName, fromDate, toDate)
dbDao = prursg.HistoricalDAO.DbHistoricalDataDao();
dataSeries = dbDao.PopulateDataSeriesContent(dataSeriesName,fromDate, toDate, fromDate, '', '');
end

function dataSeriesToMDS(dso)
daoDB = prursg.HistoricalDAO.DbHistoricalDataDao();
daoDB.WriteData(dso);
end

function dataSeriesToXML(dso, inputDir, outputDir)
xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
xmlDao.InputDir = inputDir;
xmlDao.OutputDir = outputDir;
xmlDao.WriteData(dso);
end
