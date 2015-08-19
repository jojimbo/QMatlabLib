% A concrete implementation of the IRSGCorrelationMatrixSource interface.
% This class provides support for filesystem based Microsft Excel 
% correlation matrices
classdef CorrelationMatrixXlsSource < prursg.CorrelationMatrix.CorrelationMatrixFileSource
    properties
        % The name of the workbook sheet containing the Names of the
        % correlation entries
        NameSheet = 'names'
        
        % The name of the workbook sheet containing the correlation entries
        DataSheet = 'psd'

        % Ordered names corresponding to Values
        % See IRSGCorrelationMatrixSource:Names
        names = {}
        
        % An [n,n] cell array of ordered values corresponding to Names.
        % See IRSGCorrelationMatrixSource:Values
        values = {}  
        
        % A flag which if set to a value > 0 will output additional log 
        % to aid debugging. Set to zero (the defaultto disable), 1 or 2.
        % Note that setting to 2 produces a lot of output and approximately
        % double the processing time
        Verbosity = 0;
        
        % The types of Microsoft XLS files supported by this
        % correlation matrix source (and by extension, Apache POI)
        patterns = {'.xlsx', '.xls', '.xlsm'};
    end
    
    methods
        % in:
        %   controlFile, An object that implements the IControlFile
        %   interface
        function obj = CorrelationMatrixXlsSource(controlFile)
           obj = obj@prursg.CorrelationMatrix.CorrelationMatrixFileSource(...
               controlFile.controlFilePath);
        end
         
        % Convert the cell array to a matrix
        function matrix = get.values(obj)
            matrix = cell2mat(obj.values);
        end
        
        % This is a concrete implementation of the abstract
        % IRSGCorrelationMatrixSource readCorrelationMatrix method. It 
        % reads a correlation matrix from an Microsft Excel workbook on 
        % the filesystem
        function result = readCorrelationMatrix(obj)
            try
                files = obj.findFiles(obj.patterns);
                if isempty(files)
                    fprintf('No correlation matrix found!\n');
                    result = false;
                elseif length(files) > 1
                    fprintf('More than one candidate correlation matrix was found!\n');
                    disp(files);
                    throw(MException('CorrelationMatrixXlsSource:readCorrelationMatrix',...
                        'Ambiguous correlation matrix'));
                else
                    result = obj.read(files{1});
                end
            catch e
                fprintf(['\nCorrelationMatrixXlsSource:Error: Caught an exception '...
                    'whilst reading the correlation matrix: \n%s\n'], e.message);
                result = false;
            end
        end
    end
    
    methods (Access=private)
        % Read the correlation data and names from an XLS file.
        % Note the current implementation relies on the input being
        % correctly formatted. The names sheet should contain
        % strings and the psd sheet doubles. This function does not defend
        % against strings appearing in the psd sheet or vice versa.
        % in: 
        %   file, The XLS file from which to read
        % out: 
        %   result, True on success, false otherwise
        function result = read(obj, file)
            try
                import java.io.FileInputStream;
                import org.apache.poi.ss.usermodel.WorkbookFactory;
                import org.apache.poi.ss.usermodel.Workbook;

                in = FileInputStream(file);    
                wb = WorkbookFactory.create(in);
                
                obj.names = obj.read_sheet(wb, obj.NameSheet);           
                obj.values = obj.read_sheet(wb, obj.DataSheet);
                result = true;
            catch e
                fprintf('\nError: Caught an exception whilst reading the correlation matrix from file: \n%s\n', e.message);
                result = false;
            end            
        end
        
        % Read the XLS sheet from the workbook
        % in: 
        %   workbook, The book containing the sheet
        % in: 
        %   sheet, The sheet from which to read data
        % out: 
        %   data, An N*M matrix or an exception on error
        function data = read_sheet(obj, workbook, sheetName)
            sheetIndex = workbook.getSheetIndex(sheetName);
            sheet = workbook.getSheetAt(sheetIndex);
            
            numRowsWithData = obj.getRowCount(sheet);
            numColsWithData = obj.getColCount(sheet);
            data = cell(numRowsWithData, numColsWithData);
            
            fprintf('\nProcessing sheet "%s", expecting %d rows\n',... 
                sheetName, numRowsWithData);

            for i = 0:(numRowsWithData - 1) % zero based
                
                if obj.Verbosity == 1
                    % printing this out adds only about 10 seconds
                    if ~mod(i, 50)
                        fprintf('%d rows remaining\n', numRowsWithData - i);
                    end
                end
                
                xlsrow = sheet.getRow(i);
                for j = 0:(numColsWithData - 1) % zero based
                    xlscell = xlsrow.getCell(j);
                    
                    import org.apache.poi.ss.util.CellReference;
                    cellref = CellReference(i, j); 
                    value = parseCell(obj, xlscell, cellref);
                    data{i + 1, j + 1} = value;
                end
            end
        end

        % Parse the cell checking it's one of the allowed types
        % in: xlscell, a HSSFCell
        % in: cellref, a cell reference used for error logging
        % out: the parsed value or an exception in the case of error
        function value = parseCell(obj, xlscell, cellref)

             if obj.Verbosity == 2
                 % printing this approximately double the processing time
                 fprintf('%s, %s, %s\n',...
                     char(cellref.formatAsString()),...
                     obj.cellTypeToString(xlscell),...
                     char(xlscell.getRawValue()));
             end
       
            switch xlscell.getCellType
                case xlscell.CELL_TYPE_STRING
                    % cast from Java string to Matlab representation 
                    value = char(xlscell.getStringCellValue());
                case xlscell.CELL_TYPE_NUMERIC
                    % cast from Java double to Matlab representation                   
                    value = double(xlscell.getNumericCellValue());
                otherwise
                    fprintf(['Correlation matrix workbook cells are'...
                        ' expected to be of type string or numeric. '...
                        ' Found cell (%s) of type (%s)'],...
                        char(cellref.formatAsString()),...
                        obj.cellTypeToString(xlscell));
                    throw(MException('CorrelationMatrixXlsSource:readCorrelationMatrix:MalformedCell',...
                        'Correlation matrix workbook cells are expected to be of type string or numeric' ));
            end
        end
        
        % Determine the number of rows in a sheet.
        % in: sheet, a HSSFSheet
        % out: index, the number of the last cell in the sheet
        function num = getRowCount(obj, sheet)
            % Zero based row numbering so need to add one
            num = sheet.getLastRowNum() + 1;
        end  
        
        % Determine the number of columns in a sheet. We assume data is not
        % jagged as the column index is determined from the first row
        % in: sheet, a HSSFSheet
        % out: index, the number of the last cell in the sheet
        function num = getColCount(obj, sheet)
            xlsrow = sheet.getRow(0);
            num = xlsrow.getLastCellNum();           
        end 
        
        % Get the cell type as string
        function str = cellTypeToString(obj, xlscell)
            switch xlscell.getCellType
                case xlscell.CELL_TYPE_STRING
                    str = 'CELL_TYPE_STRING';
                case xlscell.CELL_TYPE_NUMERIC
                    str = 'CELL_TYPE_NUMERIC';
                case xlscell.CELL_TYPE_BLANK
                    str = 'CELL_TYPE_BLANK';
                case xlscell.CELL_TYPE_FORMULA
                    str = 'CELL_TYPE_FORMULA';
                case xlscell.CELL_TYPE_BOOLEAN
                    str = 'CELL_TYPE_BOOLEAN';
                case xlscell.CELL_TYPE_ERROR
                    str = 'CELL_TYPE_ERROR';
                otherwise
                    str = 'Unknown!';
            end
        end
    end
end