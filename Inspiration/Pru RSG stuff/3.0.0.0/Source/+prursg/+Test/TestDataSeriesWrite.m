%clear import;
%clear;
%clc;
import prursg.HistoricalDAO.*;
folderName = 'marketData';
DAO = HistoricalDAO(folderName);
%dataObj = DAO.populateData('GBP_equityvol_asx','09/09/2010','17/09/2010');
%[data dates] = dataObj.getData(2,1);
%[data dates] = dataObj.getDataByName(5,1.3);
name0 = 'HKD_fx';
name1 = 'GBP_nyc';
name2 = 'GBP_equityvol_asx';
dataObj1 = DAO.populateData(name0,'31/12/2008','31/10/2009');
dataObj2 = DAO.populateData(name1,'31/12/2008','31/10/2009');
dataObj3 = DAO.populateData(name2, '01/01/2007', '31/10/2009');
csvPath = fullfile(pwd, folderName, [name1 '.ser.csv' ]);
dsw = DataSeries2Csv();
dsw.writeCsv(csvPath, dataObj2);
csvPath = fullfile(pwd, folderName, [name2 '.ser.csv' ]);
dsw.writeCsv(csvPath, dataObj3);
csvPath = fullfile(pwd, folderName, [name0 '.ser.csv' ]);
dsw.writeCsv(csvPath, dataObj1);

% NOTES to shaun
% ascending dates
% dates formatted as dd/mm/yyyy
% check no N/A in data
% example usage of getData and getDataByName