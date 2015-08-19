function destroyJobFcn(scheduler, job)
%DESTROYJOB Destroys a job on Symphony 
%
% Set your scheduler's DestroyJobFcn to this function using the following
% command:
%     set(sched, 'DestroyJobFcn', @destroyJobFcn);

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2012/01/26 15:05:49GMT $

% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if ~scheduler.HasSharedFilesystem
    error('distcompexamples:Symphony:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end
 % Get the information about the actual scheduler used
data = scheduler.getJobSchedulerData(job);
if isempty(data)
    % This indicates that the job has not been submitted, so just return
    dctSchedulerMessage(1, '%s: Job scheduler data was empty for job with ID %d.', currFilename, job.ID);
    return
end
try
    appname = data.SchedulerAppName;
    user = data.SchedulerAppUser;
    passwd = data.SchedulerAppPasswd;
    ssnID = data.SchedulerSsnID;
catch err
    ex = MException('distcompexamples:Symphony:FailedToRetrieveJobID', ...
        'Failed to retrieve scheduler''s session ID from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end

% The proxy name is 'mlproxy'
proxyCmd = 'mlproxy';
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
proxyCmd = sprintf('%s', fullfile(dirpart, proxyCmd));
% Did proxy exist in MATLAB working directory?
if ~exist(proxyCmd, 'file')
  proxyCmd = 'mlproxy';
end

% Get the scheduler to destroy the session
commandToRun = sprintf('%s close -s %d -a %s -u %s -x %s', proxyCmd, ssnID, appname, user, passwd);
dctSchedulerMessage(4, '%s: Destroying job on scheduler using command:\n\t%s.', currFilename, commandToRun);
try
    % Make the shelled out call to run the command.
    [cmdFailed, cmdOut] = system(commandToRun);
catch err
    cmdFailed = true;
    cmdOut = err.message;
end
       
if cmdFailed
    % Keep track of session that errored when being destroyed.  We'll
    % report these later on.
    dctSchedulerMessage(1, '%s: Failed to destroy session %d on scheduler.  Reason:\n\t%s', currFilename, ssnID, cmdOut);
end
