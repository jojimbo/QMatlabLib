classdef ScheduleGenerator
    %SCHEDULEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        periodMap;
    end
    
    methods
        function obj= ScheduleGenerator()
            obj.periodMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
            obj.periodMap('d') = 'day';
            obj.periodMap('m') = 'month';
            obj.periodMap('y') = 'year';
        end
    end
    
    methods
        function schedules = GenerateSchedules(obj, fromDate, toDate, frequency, dateOfMonth)
            schedules = {};
            if isempty(fromDate) || isempty(toDate)
                ex = MException('ScheduleGenerator:GenerateSchedules', 'Both fromDate and toDate must be provided.');                
                throw(ex);
            end
            if ~isempty(frequency)
                if (regexpi(frequency, '[0-9]*[DWM]'))
                    period = frequency(end);
                    prefix = 1;
                    if length(frequency) > 1
                        prefix = str2num(frequency(1:end-1));
                    end

                    startDate = datenum(fromDate);                    
                    toDate = datenum(toDate);
                    if strcmpi(period, 'w')
                        prefix = prefix * 7;
                        period = 'd';
                    end 

                    switch (period)
                        case {'d', 'y'}
                            schedules{end + 1} = startDate;
                            translatedCode = obj.periodMap(period);
                            newDate = addtodate(startDate, prefix, translatedCode);
                            while(newDate <= toDate)
                                schedules{end + 1} = newDate;
                                newDate = addtodate(newDate, prefix, translatedCode);
                            end        
                        case 'm'
                            translatedCode = obj.periodMap(period);

                            [y, m] = datevec(datestr(startDate));
                            d = eomday(y, m);
                            if ~isempty(dateOfMonth) 
                                if isnumeric(dateOfMonth)
                                    d = dateOfMonth;
                                else
                                    d = str2num(dateOfMonth);
                                end
                            end

                            newDate = datenum(y, m, d);                
                            while(newDate <= toDate)
                                if (newDate >= startDate)
                                    schedules{end + 1} = newDate;
                                end
                                newDate = addtodate(newDate, prefix, translatedCode);                    
                                [y, m] = datevec(datestr(newDate));
                                d = eomday(y, m);
                                if ~isempty(dateOfMonth)
                                   if isnumeric(dateOfMonth)
                                        d = dateOfMonth;
                                    else
                                        d = str2num(dateOfMonth);
                                    end
                                end
                                newDate = datenum(y, m, d);                
                            end        
                    end

                end    
            end
        end
    end    
end

