function filesExist = areThereFilesInTheDirectory(dirPath)

    listing = dir(dirPath);
    
    [~,dx]=sort([listing.datenum]);
    
    folderName = listing(dx(end)).name;
    
    listingFolder = dir(fullfile(dirPath, folderName));
    isDir = [listingFolder.isdir];
    
    filesExist  = {listingFolder(~isDir).name};

end