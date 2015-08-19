%% Test_QC2893_04_order_preserved_with_3_axes_3rd_different_values
%
% SUMMARY: This tests ensures that order of the axes is preserved when and
% DSO is stored in the database and then retrieved from the database into
% another DSO and the axes values are not in any numeric order and take
% alphanumeric values. The third 'test' axis has different values. The
% input file is
% Test_QC2893_04_order_preserved_with_3_axes_3rd_different_values.xml
%
%%

function Test_QC2893_04_order_preserved_with_3_axes_3rd_different_values()
disp('Starting: Test_QC2893_04_order_preserved_with_3_axes_3rd_different_values()...')

% Set default paths
[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
addpath(regexprep(pathstr,'Tests.+$','Source'));
import prusg.*

% START OF TEST
    % input data series
    dataSeriesName = 'testcase3_3_axes_3rd_different_values';
    fromDate = '30/Dec/2011';
    toDate ='30/Dec/2011';
    % Set file paths
    inputDir = strcat(pathstr, filesep,'BootstrapInput');
    outputDir = strcat(pathstr, filesep,'BootstrapOutput');

    inDataSeries = xmlToDataSeries(dataSeriesName, inputDir, outputDir, fromDate, toDate);
    inDataSeries.Status = 1;
    inDataSeries.Purpose = 'Hey';
    
    %replace NaN values with -100.
    inDataSeries.values{1}(find(isnan(inDataSeries.values{1}))) = -100;
    
    dataSeriesToMDS(inDataSeries);
    outDataSeries = mdsToDataSeries(dataSeriesName, fromDate, toDate);
    
    assert(inDataSeries.eq(outDataSeries),...
        'NOT SUCCESSFUL: In inDataSeries.Name: %s Out outDataSeries: %s differ',...
        inDataSeries.Name, outDataSeries);    
    
    % save data series to file
    dataSeriesToXML(outDataSeries, inputDir, outputDir);

disp('Test_QC2893_04_order_preserved_with_3_axes_3rd_different_values() COMPLETE.')
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
