classdef FileUtil    
    
    properties
    end
    
    methods(Static)
        
        % Combine multiple text files into one.
        function CombineFiles(headerFileName, dataFileNames)
            if isunix
                for i = 1: size(dataFileNames, 2)
                    system(['cat "' dataFileNames{i} '" >> "' headerFileName '"']);            
                    delete(dataFileNames{i});
                end
            elseif ispc
                for i = 1: size(dataFileNames, 2)
                    system(['type "' dataFileNames{i} '" >> "' headerFileName '"']);
                    delete(dataFileNames{i});            
                end
            else
                exception = MException('FileUtil:CombineFiles', 'Not supported platform.');
                throw(exception);
            end
        end     
        
        % Create windows friendly name.
        function newName = FormatFolderName(folderName)
            newName = strrep(folderName, ':', '_');                        
            newName = strrep(newName, ':', '_');
            newName = strrep(newName, '<', '_');
            newName = strrep(newName, '>', '_');
            newName = strrep(newName, '|', '_');
            newName = strrep(newName, '?', '_');
            newName = strrep(newName, '/', '_');
            newName = strrep(newName, '\', '_');
            newName = strrep(newName, '*:', '_');
            newName = strrep(newName, '"', '_');
        end

        function furtherProcessingRequired = FurtherProcessingRequired(outputPath)
            furtherProcessingRequired = ~(exist(outputPath, 'dir') == 7) || prursg.Util.ConfigurationUtil.GetOverwriteOutputs();
        end

        function OverwriteOutputsIfRequired(outputPath)
            if prursg.Util.ConfigurationUtil.GetOverwriteOutputs() 
                % delete existing files
                if (exist(outputPath, 'dir') == 7)  
                    rmdir(outputPath, 's');
                end

                mkdir(outputPath);
            elseif ~(exist(outputPath, 'dir') == 7)
                mkdir(outputPath);
            end
        end
        
        function fileFormat = GetMatFileFormat()
            if (strcmpi(prursg.Util.ConfigurationUtil.SaveMatFilesAsHDF5(),'true'))
                fileFormat =  '-v7.3';
            elseif (strcmpi(prursg.Util.ConfigurationUtil.SaveMatFilesAsHDF5(),'legacy'))
                fileFormat =  '-v6';
            else
                fileFormat =  '-v7';
            end
        end
    end 
end

