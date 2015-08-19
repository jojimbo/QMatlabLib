function flag = SearchFileForString(fileName, stringToSearch)

    if (isunix)
        searchStatement = ['grep -li "'  stringToSearch '" ' fileName];
    else
        searchStatement = ['findstr /i /p /m "' stringToSearch '" ' fileName];
    end    
    
    txtFilesString = evalc('system(searchStatement)');
    fileNames = regexp(txtFilesString,'\n','split');  
    flag = true;
    if ~isempty(fileNames)
    	for i = 1:length(fileNames)
            txtFile = fileNames{i};
            [~, ~, ext] = fileparts(txtFile);
            if (exist(txtFile, 'file') && strcmpi(strtrim(ext), '.txt'))
                flag = false;
            end
        end
    end


end

