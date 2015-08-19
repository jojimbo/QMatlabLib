function sessionID = extractJobId(cmdOut)
% Extracts the session ID  from the mlproxy command output for Symphony

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2012/01/26 15:05:50GMT $

% The output of mlproxy will be:
% Successfully created a new session. Session ID: <704>. 
sessionNumberStr = regexp(cmdOut, 'Session ID: <[0-9]*>', 'once', 'match');
sessionID = sscanf(sessionNumberStr, 'Session ID: <%d>');
dctSchedulerMessage(0, '%s: Session ID %d was extracted from mlproxy output %s.', mfilename, sessionID, cmdOut);

