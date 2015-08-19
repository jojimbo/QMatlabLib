% Report the RSG version number as a string in the form 
% Major.Minor.Defect.Patch
function version = RSGVersion()
    import prursg.Version.*;
    instance = VersionInfo.instance();
    version = instance.RSGVersion;
end