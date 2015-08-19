function fromXMLtoMDS(DataSeriesName, xmlfilepath)
% This script just grabs an XML file with a DataSeries in it
% and saves that DataSeries into the MDS data base


dao = prursg.HistoricalDAO.XmlHistoricalDataDao();
%dao.InputFileName = '/nfs/lldnfs01v/matlab/code/llwsolv109/2011_12_06/iRSG/Source/Tests/Outputs/usd_nyc_zcb_na_na_mth_noadj_derived.xml';
dao.InputFileName = xmlfilepath;
dao.DataSource = prursg.HistoricalDAO.XmlDataSource.File;
%DataSeriesOut = dao.PopulateDataSeriesContent('usd_nyc_zcb_na_na_mth_noadj_derived','26/Dec/2009','31/Dec/2009','','', '');
DataSeriesOut = dao.PopulateDataSeriesContent(DataSeriesName,'26/Dec/2009','31/Dec/2009','','', '');
daoDB = prursg.HistoricalDAO.DbHistoricalDataDao();
daoDB.WriteData(DataSeriesOut);

end