function submitString = getSubmitString(proxyCmd, ssnID, appname, user, passwd, command, ...
    matlabSubmitArgs)
%GETSUBMITSTRING Gets the correct mlproxy command for an Symphony scheduler

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2012/01/26 15:05:51GMT $

% Submit to Symphony using mlproxy.  Note the following:
% "-s" - specifies session ID
% "-a" - specifies application name
% Deduce the correct quote to use based on the OS of the current machine

if ispc
    quote = '"';
else
    quote = '''';
end
	 
submitString = sprintf('%s send -s %d -a %s -u %s -x %s %s%s %s%s', ...
               proxyCmd, ssnID, appname, user, passwd, quote, ...
	       command, matlabSubmitArgs, quote);
