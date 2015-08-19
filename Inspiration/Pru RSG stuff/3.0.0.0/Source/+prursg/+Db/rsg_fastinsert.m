function rsg_fastinsert(connect,tableName,fieldNames,data)
%FASTINSERT Export MATLAB cell array data into database table.
%
% exact copy of standard fastinsert, but with support for oracle's
% binary_double datatype. The original fastinsert passes valuetype=101
% via statement.setObject which converts the doubles into oracle 'number'
% type, which has lower range than binary_double
%

%startungTime = tic;

error(nargchk(4,4,nargin));

% Check for valid connection

if isa(connect.Handle,'double')
   
    error('database:fastinsert:invalidConnection','Invalid connection.')
   
end

% Create start of the SQL insert statement
% First get number of columns in the cell array 

%Get dimensions of data
switch class(data)
    
  case {'cell','double'}
    [numberOfRows,cols] = size(data);	%data dimensions
    
  case 'struct'
    sflds = fieldnames(data);
    fchk = setxor(sflds,fieldNames);
    if ~isempty(fchk)
      error('database:fastinsert:fieldMismatch','Structure fields and insert fields do not match.')
    end
    numberOfRows = size(data.(sflds{1}),1);
    cols = length(sflds);
    
    %Get class type of each field to be used later
    numberOfFields = length(sflds);
    fieldTypes = cell(numberOfFields,1);
    for i = 1:numberOfFields
      fieldTypes{i} = class(data.(sflds{i}));
    end

  case 'dataset'
    dSummary = summary(data);
    sflds = {dSummary.Variables.Name};
    fchk = setxor(sflds,fieldNames);
    if ~isempty(fchk)
      error('database:database:writeMismatch','Dataset variable names and insert fields do not match.')
    end
    numberOfRows = size(data.(sflds{1}),1);
    cols = length(sflds);
    
    %Get class type of each field to be used later
    numberOfFields = cols;
    fieldTypes = cell(numberOfFields,1);
    for i = 1:numberOfFields
      fieldTypes{i} = class(data.(sflds{i}));
    end
    
  otherwise
    error('database:fastinsert:inputDataError','Input data must be a cell array, matrix, or structure')
   
end

% Case 1 all fields are being written to in the target database table.
insertField = '';
tmpq = '';

% Create the field name string for the INSERT statement .. this defines the
% fields in the database table that will be receive data.
% Also build variable ?'s string for later set* commands

for i=1:cols,
  if ( i == cols),
    insertField = [ insertField fieldNames{i}];  %#ok
    tmpq = [tmpq '?)'];                          %#ok
  else
    insertField = [ insertField fieldNames{i} ',' ]; %#ok
    tmpq = [tmpq '?,'];                              %#ok
  end	
end

% Create the head of the SQL statement
startOfString = [ 'INSERT INTO '  tableName ' (' insertField ') ' 'VALUES ( ' ];

% Get NULL string and number preferences 
prefs = setdbprefs({'NullStringWrite','NullNumberWrite'});
nsw = prefs.NullStringWrite;
nnw = str2num(prefs.NullNumberWrite);    %#ok

%Create prepared statement object
tmpConn = connect.Handle;
StatementObject = tmpConn.prepareStatement([startOfString tmpq]);

%Get Database name
dMetaData = dmd(connect);
sDbName = get(dMetaData,'DatabaseProductName');

%Determine type values by fetching one row of data from table
switch sDbName  %Query only a single row where possible for speed
      
  case {'MySQL'}
    e = exec(connect,['select ' insertField ' from ' tableName ' LIMIT 0']);
  case {'Microsoft SQL Server','ACCESS'}
    e = exec(connect,['select TOP 1 ' insertField ' from ' tableName]);
  case {'Oracle'}
    e = exec(connect,['select ' insertField ' from ' tableName ' where ROWNUM <= 1']);  
  otherwise
    e = exec(connect,['select ' insertField ' from ' tableName]);    
end
if ~isempty(e.Message)
  error('database:database:insertError',e.Message)
end
e = fetch(e,1);
if ~isempty(e.Message)
  error('database:database:insertError',e.Message)
end
a = attr(e);
close(e)

for i = 1:numberOfRows,  
  
    for j = 1:cols
     
      switch class(data)
        
        case 'cell'

          tmp = data{i,j}; 
          
        case 'double'
            
          tmp = data(i,j);     
        
        case {'struct','dataset'}
          
          switch fieldTypes{j}
            
            case 'cell'
          
              tmp = data.(sflds{j}){i};
          
            case 'double'
              
              tmp = data.(sflds{j})(i);
              
            case 'char'
              
              tmp = data.(sflds{j})(i,:);
              
          end
        
      end  
      
      %Check for null values and setNull if applicable
      if (isa(tmp,'double')) & ...
         ((isnan(tmp) | (isempty(tmp) & isempty(nnw))) | (~isempty(nnw) & ~isempty(tmp) & tmp == nnw) | (isnan(tmp) & isnan(nnw)))  %#ok
          
         StatementObject.setNull(j,a(j).typeValue)
        
      elseif (isnumeric(tmp) && isempty(tmp))
        
        % Insert numeric null (for binary objects), using -4 fails
        StatementObject.setNull(j,7)
      
      elseif (isa(tmp,'char')) && ...
             ((isempty(tmp) && isempty(nsw)) || strcmp(tmp,nsw))
      
         StatementObject.setNull(j,a(j).typeValue)
      
      else
        
        switch a(j).typeValue
         
          case 101
            StatementObject.setBinaryDouble(j, tmp); % support for oracle's IEEE BINARY_DOUBLE
          case -7
            StatementObject.setBoolean(j,tmp)  %BIT
          case -6
            StatementObject.setByte(j,tmp)  %TINYINT
          case -5
            StatementObject.setLong(j,tmp)  %BIGINT
          case {-4, -3, 2004}
            StatementObject.setBytes(j,tmp)  %LONGVARBINARY, VARBINARY
          case {-10, -9, -8, -1, 1, 12}
            StatementObject.setString(j,java.lang.String(tmp))  %CHAR, LONGVARCHAR, VARCHAR
          case {2, 3, 7}
            StatementObject.setDouble(j,tmp)  %NUMERIC, DECIMAL, REAL
          case 4
            StatementObject.setInt(j,tmp)  %INTEGER
          case 5
            StatementObject.setShort(j,tmp)  %SMALLINT
          case 6
            StatementObject.setDouble(j,tmp)  %FLOAT
          case 8
            StatementObject.setDouble(j,tmp)  %DOUBLE
          case 91
            dt = datevec(tmp);
            StatementObject.setDate(j,java.sql.Date(dt(1)-1900,dt(2)-1,dt(3)))  %DATE
          case 92
            tt = datevec(tmp);
            StatementObject.setTime(j,java.sql.Time(tt(4),tt(5),tt(6)))  %TIME
          case 93
            ts = datevec(tmp);
            %Need whole second value to calculate nanosecond value
            secs = floor(ts(6));
            nanosecs = (ts(6) - secs) * 1000000000;
            StatementObject.setTimestamp(j,java.sql.Timestamp(ts(1)-1900,ts(2)-1,ts(3),ts(4),ts(5),secs,nanosecs))  %TIMESTAMP
          case {-2,1111}
            error('database:fastinsert:unsupportedDatatype',['Unsupported data type in field ' fieldNames{j}])
          otherwise
            StatementObject.setObject(j,tmp);   %OBJECT
            
        end   %End of switch
      end  %End of datatype and null value check
    end  %End of j loop

    % Add parameters to statement object
    StatementObject.addBatch;
  
end  % End of numberOfRows loop

%Execute prepared statement batch
StatementObject.executeBatch;

close(StatementObject)

%fprintf('rsg_fastinsert into table %s\n', tableName);
%toc(startungTime);
