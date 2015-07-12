function name = createMasterFile(path)

s = what(path);

if numel(s.m)<2
    name=0;
    return
end

if numel(s.m)==2
    mFiles = s.m;
    if strcmp(mFiles{1,1},'master.m')||strcmp(mFiles{2,1},'master.m')
        name=0;
        return
    end
end


s=s.m;

name = strcat(path,'\master.m');

fid = fopen(name,'w');

d = ['%% ', path];

fprintf(fid,'%s\n',d);

for i = 2 : numel (s)
    [~,b,~]=fileparts(char(s(i)));
    d = ['.html ',b];    
    string = strcat('% <',b,d,'>');
    if ~strcmp(b,'master')
        fprintf(fid,'%s\n','%');
        fprintf(fid,'%s\n',string);        
    end
end

fclose(fid);