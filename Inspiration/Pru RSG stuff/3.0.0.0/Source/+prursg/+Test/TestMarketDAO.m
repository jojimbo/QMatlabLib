clear import;
clear;
clc;
import prursg.HistoricalDAO.*;
DAO = HistoricalDAO('marketData');
%dataObj = DAO.populateData('GBP_equityvol_asx','09/09/2010','17/09/2010');
%[data dates] = dataObj.getData(2,1);
%[data dates] = dataObj.getDataByName(5,1.3);
dataObj2 = DAO.populateData('TEST_VS_1','29/06/2001','31/01/2010');
%[data dates] = dataObj2.getData();
[data dates] = dataObj2.getDataByName(100,5,10);
DAO.writeData('JL_TEST_VS_1',dataObj2);
%dataObj3 = DAO.populateData('TEST_EQUITY_2','31/10/2008','30/09/2009');
%[data dates] = dataObj3.getData();
%[data dates] = dataObj3.getDataByName();

% NOTES on market data csv file format
% ascending dates
% dates formatted as dd/mm/yyyy
% check no N/A in data
% if 3D, data must be entered by holding 1st dimension constant, 2nd
% dimension constant, exhaust 3rd dimension, then move to the second value
% of 2nd dimension, exhaust 3rd dimension and so on...
% example usage of getData and getDataByName