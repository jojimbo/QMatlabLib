% MATLAB calls the clear java command whenever you change the dynamic path.
% 
%   CLEAR JAVA is the same as CLEAR ALL except that java classes on the
%   dynamic java path (defined using JAVACLASSPATH) are also cleared. 
% 
%   CLEAR ALL removes all variables, globals, functions and MEX links.
%   CLEAR ALL at the command prompt also removes the Java packages import
%   list.
% 
%   Therefore - WE MUST ENSURE THIS METHOD IS CALLED VERY EARLY IN THE
%   PROCESS OR UNEXPECTED BEHAVIOUR WILL RESULT
function found = configureJava(enable)
%ADDJAVAPATH Add pru rsg java folder to matlab's classpath
    rootFolder = prursg.Util.ConfigurationUtil.GetRootFolderPath();
    prursgJavaFolder = fullfile(rootFolder, '+prursg', 'java'); 
    
    %prursgJavaFolder = '/home/ageorgiev/workspace/derby/bin';
    cp = javaclasspath('-dynamic');
    found = sum(strcmp(cp, prursgJavaFolder)) > 0;

    if enable
        if ~found
            javaaddpath(prursgJavaFolder);
        end
        % manipulate constant(almost static) fields of XML daos:
        m = prursg.Xml.SerialisedHyperCubeDao.useJava;
        m('useJava') = 'true';
    else
        if found
            javarmpath(prursgJavaFolder);
        end
        % disable java usage by xml daos:
        clearMap(prursg.Xml.SerialisedHyperCubeDao.useJava);
    end
end

function clearMap(m)
    k = keys(m);
    for i = 1:numel(k)
        remove(m, k{i});
    end        
end

