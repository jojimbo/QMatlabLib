
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 1. Clear previous data and
	clear;
	clc;
    
    tic
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 2. Specify the location of data series and the output location
    % of files to be created :: Use path relative to current folder
	
    RawDataPath = '\marketData';
    outfilePath = '\marketData';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 3. Specify the name (string) for  each of the data series
    % objects
    
	sInputZCBDataSeries = 'usd_nyc_values_raw';  
    
    sOutputDataSeries = 'usd_nyc_zcb_na_na_mth_noadj_derived';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 4a. Import data series for each of the given dates, using DAO object class
    % where we dynamically add properties/ fields to the data   
   
    dateStart = '31/12/2009';
	dateEnd = '31/12/2009';       
    
	DAO = prursg.HistoricalDAO.HistoricalDAO_DynamicV3(RawDataPath);
    DAO2 = prursg.HistoricalDAO.HistoricalDAO_DynamicV3(outfilePath);
  
    InputZCBDataSeries  = DAO.populateData(sInputZCBDataSeries,dateStart, dateEnd);
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 4b.Add additional data series information using dynamically defined properties    
    % Set-Up Data Series Object    
    
    InputZCBDataSeries.addprop('description');    
    InputZCBDataSeries.addprop('ratetype');
    InputZCBDataSeries.addprop('compounding');
    InputZCBDataSeries.addprop( 'compoundingfrequency');
    InputZCBDataSeries.addprop('daycount') ;
    InputZCBDataSeries.addprop('units') ;
    
    InputZCBDataSeries.description = {'par swap rates'};
    InputZCBDataSeries.ratetype = {'swap'};
    InputZCBDataSeries.compounding ={'ann'};
    InputZCBDataSeries.compoundingfrequency = {2};
    InputZCBDataSeries.daycount ={365};
    InputZCBDataSeries.units ={'percent'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 5. Specify the additional parameters used to control the
    % bootstrap method
 
    outputfreq = '0001,0000,000,000'; 
    ltfwd = 0.042;
    llp = 50;
    decayrate = 0.1;   
    startterm = 0;
    endterm = 135;
    method = 'Wilson Smith';
    
    ParametersIn{1} =outputfreq;
    ParametersIn{2} =ltfwd;
    ParametersIn{3} =llp;
    ParametersIn{4} =decayrate;
    ParametersIn{5} =startterm;
    ParametersIn{6} =endterm;
    ParametersIn{7} ='Wilson Smith';
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 6. apply bootrapping method to the input data series objects and
    % parameters
	      
    
    dataObjOut = Bootstrap_DataSeries(InputZCBDataSeries, ParametersIn,'bootstrap_RawtoZCB');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 7. Ouput Dataseries    
      
     DAO2.writeData( sOutputDataSeries, dataObjOut);
    
    toc
    