classdef DataSeries2Csv
    %DATASERIES2CSV Static interface to serialise a data series to CSV
    %   CSV contains spec of dimensions followed by dates with data
    properties
        fid
    end
    
    methods
        function obj=DataSeries2Csv()
        end
        function writeCsv(obj, fileName, dataSeries)
            import prursg.Engine.*;
         
            obj.fid = fopen(fileName, 'w');
            if obj.fid < 0
                return
            end
            obj.writeSeries(dataSeries);
            fclose(obj.fid);
        end
    end

    methods (Access = private)
        function writeSeries(obj, dataSeries)
            obj.writeHeader(dataSeries);
            % No handling of dimensionality required for data series
            % everything can now be written sequentially
            % after cells are transposed.
            for i=1:numel(dataSeries.dates)
                fprintf(obj.fid, '%s', dataSeries.dates{i});
                sT=dataSeries.values{i}';
                for j=1:numel(sT)
                    fprintf(obj.fid, ',%g', sT(j));
                end
                fprintf(obj.fid, '\n');
            end
        end
        function writeHeader(obj, dataSeries)
            % write header info. Will include two lines
            % values in leading headers need repetition for permutations
            % of values of headers below
            mult = ones(numel(dataSeries.axes),1);
            rept = ones(numel(dataSeries.axes),1);
            if numel(mult) > 1
                for i=numel(dataSeries.axes):2
                    mult(i-1)=numel(dataSeries.axes(i).values)*mult(i);
                end
                for i=2:numel(dataSeries.axes)
                    rept(i)=rept(i-1)*numel(dataSeries.axes(i-1).values);
                end
            end
            for i=1:numel(dataSeries.axes)
                fprintf(obj.fid, '%s', dataSeries.axes(i).title);
                for k=1:rept(i)
                    for j=1:numel(dataSeries.axes(i).values)
                        for l=1:mult(i)
                            fprintf(obj.fid, ',%g', dataSeries.axes(i).values(j));
                        end
                    end
                end
                fprintf(obj.fid, '\n');
            end
        end
    end
end

