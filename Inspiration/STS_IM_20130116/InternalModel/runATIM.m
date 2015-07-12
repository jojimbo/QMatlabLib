function [ ] = runATIM()
    currentDir = pwd;
    [ dirCode, dirConfig, dirReport, dirBaseline] = getDir( 'r', 'b', 'c' );

    
    c = clock;
    d = date;
    strtime = [d 'hr' num2str(c(4)) '-' num2str(c(5))];
    
    csvName = ['AT_IM_report_' strtime '.txt'];
    csvFile = [dirReport,filesep,csvName];
    
    if ~exist(dirReport, 'file')
        mkdir(dirReport);
    end
    diary(csvFile);
    
    cd(dirCode);
    list = dir(dirConfig);

    freport = cellstr(['Test executed in directory: ' pwd]);
    freport = [freport ['DATE: ' date]];
    freport = [freport ['dir Config: ' dirConfig]];
    freport = [freport ['dir Report: ' dirReport]];
    freport = [freport ['dir Baseline: ' dirBaseline]];
    configFilesList = cellstr('Configuration files used: ');
    
    
    P = cellstr('');
    F = cellstr('');
    E = cellstr('');
    listOfReportsToBeChecked = [];
    for i=3:length(list) % ignore ".", ".."
        try
            configName = list(i).name;
            configFilesList = [configFilesList configName];
            configFile = [dirConfig,filesep,configName];
                      
            fclose('all');
            %run STS
            answer = STS_CM(configFile);
            %get report's path
            reportPath = [answer.cube.path filesep ];
            
            %load parameters from config file
            params = internalModel.Utilities.loadParamsFromConfigFile(configFile);
            c = length(params.confidenceLvl);
            r = length(params.reportingCurrency);
            
            freport = [freport ['Successful running and loading of configfile ' configName ]];
            
            listOfReportsToBeChecked = cellstr(['%%% List of reports to be checked for: ' configName ]);
            [~,name,~] = fileparts(params.outputFile);
            n = 0;
            for ci=1:c
                for ri=1:r
                    n = n + 1;
                    temp_listOfReportsToBeChecked{n} = [ reportPath name '_'  params.reportingCurrency{ri} '_' num2str(params.confidenceLvl(ci)) '.csv'];
                end               
            end
            for k=1:length(temp_listOfReportsToBeChecked)
                listOfReportsToBeChecked = [listOfReportsToBeChecked temp_listOfReportsToBeChecked{k}];
            end

            
            tempstr = [reportPath 'Cube.mat'];
            listOfReportsToBeChecked = [listOfReportsToBeChecked tempstr];


            for j=1:length(listOfReportsToBeChecked)
                freport = [freport ['    ' listOfReportsToBeChecked{j}]];
            end
               
            
            
        catch error
            tempstr = ['Error in STS_CM: ' configName ': ' error.message];
            E = [E tempstr];
            freport = [freport [tempstr]];
        end   
        
         %start comparing
        freport = [freport ['  ### START comparing reports for: ' configName ]];
        [report, p, f, e] = checkResults(configName, listOfReportsToBeChecked, dirBaseline, freport, P, F, E);
        P = p;
        F = f;
        E = e;
        freport = report;
        freport = [freport ['  ### END : '  configName '###']];

    end
    
    disp('++++++++++++++++++++++++++++++++++++++++++++++++ Final Report ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    for j=1:length(configFilesList)
        disp(configFilesList{j});
    end
    disp(' ');
    for i=1:length(freport)
        disp(freport{i}); 
    end
    nrP = length(P);
    nrF = length(F);
    nrE = length(E);
    disp(' ');
    disp('PASSED');
    disp(' ');
    for i=1:nrP
        disp(P{i});
    end 
    disp(' ');
    disp('FAILED');
    disp(' ');
    for i=1:nrF
        disp(F{i});
    end
    disp(' ');
    disp('ERRORS');
    disp(' ');
    for i=1:nrE
        disp(E{i});
    end
    disp('');
    disp('TOTAL:');
    disp([num2str(nrF-1) ' Failed, ' num2str(nrP-1) ' Passed, and ' num2str(nrE-1) ' Errors']);
    disp('++++++++++++++++++++++++++++++++++++++++++++++++ Final Report ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

    fclose('all');

    diary('off');


    cd(currentDir);
end

function [ report, p, f, e ] = checkResults( ID , listOfReportsToBeChecked, dirBaseline, freport, P, F, E)
    
for i=2:length(listOfReportsToBeChecked)
    [~,file,ext] = fileparts(listOfReportsToBeChecked{i});
    idx = strfind(listOfReportsToBeChecked{i},filesep);
    folder = listOfReportsToBeChecked{i}(idx(length(idx)-2)+1:idx(length(idx)-1)-1);
    
        if strcmp(ext,'.mat')            
           folder = listOfReportsToBeChecked{i}(idx(length(idx)-2)+1:idx(length(idx)-1)-1);
           
           if (exist([dirBaseline filesep folder filesep 'Cube.mat'],'file') && exist(listOfReportsToBeChecked{i},'file'))
                cubeData = load(listOfReportsToBeChecked{i});
                cubeData_base = load([dirBaseline filesep folder filesep 'Cube.mat']);
           
               if isequal(cubeData.obj.data, cubeData_base.obj.data)
                    freport = [freport ['PASSED check CUBE: ' file ext ]];
                    tempstr = [ID ' : ' file ext];
                    P = [P tempstr];
               else
                    tempstr = [ID ' : ' file ext];
                    F = [F tempstr];
                    freport = [freport ['FAILED check CUBE: ' file ext ]];
               end
               clear cubeData;
               clear cubeData_base;
           else
                tempstr = ['Error check Results: ' ID ' : ' file ext ' file does not exist'];
                freport = [freport tempstr];
                E = [E tempstr];
           end
        else
            if (exist([dirBaseline filesep folder filesep file ext],'file') && exist(listOfReportsToBeChecked{i},'file'))            
        
                f1a=readCSV([dirBaseline filesep folder filesep file ext],0);
                f1b=readCSV(listOfReportsToBeChecked{i},0);

                if isequal(f1a, f1b)
                    freport = [freport ['PASSED check Report: ' file ext ]];
                    tempstr = [ID ' : ' file ext];
                    P = [P tempstr];
                else


                    if min(size(f1a)==size(f1b))
                        tempstr = [ID ' : ' file ext];
                        F = [F tempstr];
                        [row, col] = find(strcmp(f1a,f1b)==0);
                        freport = [freport ['FAILED check Report: ' file ext ]];
                        freport = [freport ['Differences in:']];
                        freport = [freport ['row  :  col   | Baseline value    : new value ']];

                        for i=1:length(row)
                            freport = [freport [num2str(row(i)) ' : ' num2str(col(i)) '| ' f1a{row(i),col(i)} ' : ' f1b{row(i),col(i)}]];
                        end
                    else
                        tempstr = ['FAILED check Report: ' file ext ' :size mismatch'];
                        freport = [freport [tempstr]];
                        F = [F tempstr];                
                    end
                end
                 clearvars f1a;
                 clearvars f1b;
            else
                tempstr = ['Error check Results: ' ID ' : ' file ext ' file does not exist'];
                freport = [freport tempstr];
                E = [E tempstr];            
        end

    end
end
report = freport;
p = P;
f = F;
e = E;

end

function csvBody = readCSV(fullFileName, numericConvertFlag)
% Open file
[fid, errMsg] = fopen(fullFileName);

if fid < 0
    disp(['Couldn''t open file ' filename]);
    error(errMsg);
end

% Count columns
nrows = 0;
ncols = 0;

while ~feof(fid)
    nrows      = nrows + 1;
    oneLineTxt = textscan(fgetl(fid), '%s', 'delimiter', ',');
    ncols      = max(ncols, numel(oneLineTxt{1}));
end

% Read text data
frewind(fid);
formatString = repmat('%s', 1, ncols);
rawData      = textscan(fid, formatString, 'delimiter', ',', 'CollectOutput', true, 'returnonerror', 0);
csvBody      = rawData{1};

% Process numeric content:
if numericConvertFlag
    csvBodyConv         = num2cell(str2double(csvBody));
    indNumeric          = ~isnan(str2double(csvBody));
    csvBody(indNumeric) = csvBodyConv(indNumeric);
end

end % #readCSV

function [ dirCode, dirConfig, dirReport, dirBaseline] = getDir( release, baseline, config )
p = pwd;
dirReport = [p filesep 'MasterInputFiles' filesep 'ATReports'];

switch release
    case 'r'
        dirCode = p;
        
end

switch baseline
    case 'b'
        dirBaseline = [p filesep 'MasterInputFiles' filesep 'Baselines'];
  
end

switch config
        
    case 'c'
        if ispc
            dirConfig = [p filesep 'MasterInputFiles' filesep 'Configuration Files' filesep 'PCWIN64'];
        else
            dirConfig = [p filesep 'MasterInputFiles' filesep 'Configuration Files' filesep 'GLNXA64'];
        end
    
end
end

