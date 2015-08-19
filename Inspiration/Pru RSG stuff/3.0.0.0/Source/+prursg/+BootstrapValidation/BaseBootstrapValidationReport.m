classdef BaseBootstrapValidationReport < prursg.BootstrapValidation.IBootstrapValidationReport
    %%
    properties (SetAccess = public)
        Name
        Format
    end
    
    %%
    methods (Abstract)
        GenerateXmlContents(obj, fileID)
        GenerateCsvContents(obj, fileID)
        GenerateContents(obj, rpt)
    end
    
    %%
    methods
        function obj = BaseBootstrapValidationReport()
            % This are just default values
            obj.Format = 'pdf';
        end
        %%
        % The return of this function is a String contaning the path of the
        % generated report
        function path1 = Generate(obj)
            %%
            path1 = prursg.Util.ConfigurationUtil.GetOutputPath(prursg.Util.OutputFolderType.RSGBootstrapValidate, '');
            path = fullfile(path1, obj.Format);
            %This will be determined in the future by the configuration file
            %%
            
            if(exist(path, 'dir')==0)
                mkdir(path)
            end
            
            file = fullfile(path,[obj.Name '.' obj.Format]);
            %%
            switch (obj.Format)
                case 'xml'
                    fileID = fopen(file, 'w');
                    GenerateXmlContents(obj, fileID);
                    fclose(fileID);
                case 'csv'
                    fileID = fopen(file, 'w');
                    GenerateCsvContents(obj, fileID);
                    fclose(fileID);
                case 'pdf'
                    rpt = RptgenML.CReport('Description', obj.Name,...
                        'Format','pdf-fop',...
                        'Stylesheet','default-fo',...
                        'DirectoryType','pwd');
                    GenerateContents(obj, rpt);
                    file = report(rpt,strcat('-o ',file));
                    %file = rpt.execute(); %same thing
                case 'rtf'
                    rpt = RptgenML.CReport('Description', obj.Name,...
                        'Format','rtf97',...
                        'Stylesheet','!print-NoOptions',...
                        'DirectoryType','pwd');
                    GenerateContents(obj, rpt);
                    file = report(rpt,strcat('-o ',file));
                case 'doc'
                    rpt = RptgenML.CReport('Description', obj.Name,...
                        'Format','doc-rtf',...
                        'Stylesheet','!print-NoOptions',...
                        'DirectoryType','pwd');
                    GenerateContents(obj, rpt);                    
                    file = report(rpt,strcat('-o ',file));
                case 'html'
                    rpt = RptgenML.CReport('Description', obj.Name,...
                        'DirectoryType','pwd');
                    GenerateContents(obj, rpt);
                    file = report(rpt,strcat('-o ',file));
                    %file = rpt.execute(); %same thing
            end
        end
    end
    
end