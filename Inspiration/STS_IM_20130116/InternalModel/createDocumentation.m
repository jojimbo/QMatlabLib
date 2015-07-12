function res = createDocumentation()
% Create documentation for the internalModel package
% Creating the files for class folders

n = dir('+InternalModel');

for i = 1:numel(n)
    Name = n(i).name;
    
    if strcmp(Name(1),'@')
        filename = createMasterFile(char(['+InternalModel\' Name]));
        
        if filename ~=0
            outputDirectory = char(['\Documentation\InternalModel\' Name(2:numel(Name))]);
            
            publish(filename, 'showCode', false, 'evalCode', false, 'outputDir', outputDirectory);
            delete(filename);
        end
        
        
        outputDirectory = '\Documentation\InternalModel\';
        
        File = strcat(Name(2:numel(Name)),'.m');
        path = char(strcat('+InternalModel\',Name, '\'));
        publish([path File], 'showCode', false, 'evalCode', false, 'outputDir',outputDirectory);
        
        n2 = dir(path);
        
        for j = 1: numel(n2)
            if numel(n2(j).name)>2
                Name2 = n2(j).name;
                
                outputDirectory = char(['\Documentation\InternalModel\' Name(2:numel(Name))]);
                
                path = char(strcat('+InternalModel\',Name, '\'));
                publish([path Name2], 'showCode', false, 'evalCode', false, 'outputDir',outputDirectory);
            end
        end
        
        
    end
    
    
    
end

packInfo = what('+internalModel');

for iMfile = 1:length(packInfo.m)
    [~, name] = fileparts(packInfo.m{iMfile});
    outputDirectory = '\Documentation\InternalModel';
    publish(['internalModel.' name], 'showCode', false, 'evalCode', false, 'outputDir', outputDirectory);
end

% creating documentation for all packages
N = length(packInfo.packages);

for iPackages = 1 :  N
    string0 = packInfo.packages(iPackages);
    string = strcat('+internalModel\+',string0);
    packInfoPackages = what(char(string));
    for iMfile = 1:length(packInfoPackages.m)
        
        [~, name] = fileparts(packInfoPackages.m{iMfile});
        
        path = char(strcat('internalModel.',string0,'.'));
        
        outputDirectory = char(strcat('Documentation\InternalModel',filesep,string0));
        
        publish([path name], 'showCode', false, 'evalCode', false, 'outputDir',outputDirectory);
        
    end
end

% Publishing the Master File
res = publish('Documentation\Documentation.m', 'showCode', false, 'evalCode', false,'outputDir','\Documentation');