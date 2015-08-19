function state = getJobStateFcn(scheduler, job, state)
%GETJOBSTATEFCN Gets the state of a job from Symphony
%
% Set your scheduler's GetJobStateFcn to this function using the following
% command:
%     set(sched, 'GetJobStateFcn', @getJobStateFcn);

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2012/01/26 15:05:50GMT $

% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if ~scheduler.HasSharedFilesystem
    error('distcompexamples:Symphony:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end

% Shortcut if the job state is already finished or failed
jobInTerminalState = strcmp(state, 'finished') || strcmp(state, 'failed');
if jobInTerminalState
    return;
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
    numberOfTasks = data.SchedulerTasksNumber;
catch err
    ex = MException('distcompexamples:Symphony:FailedToRetrieveJobID', ...
        'Failed to retrieve scheduler''s session ID from the job scheduler data.');
    ex = ex.addCause(err);
    throw(ex);
end
 
proxyCmd = 'mlproxy';
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
proxyCmd = sprintf('%s', fullfile(dirpart, proxyCmd));
% Did proxy exist in MATLAB working directory?
if ~exist(proxyCmd, 'file')
  proxyCmd = 'mlproxy';
end

commandToRun = sprintf('%s view %s:%d -u %s -x %s', proxyCmd, appname, ssnID, user, passwd);
dctSchedulerMessage(4, '%s: Querying scheduler for job state using command:\n\t%s', currFilename, commandToRun);

try
    % We will ignore the status returned from the state command because
    % a non-zero status is returned if the job no longer exists
    % Make the shelled out call to run the command.
    [cmdFailed, cmdOut] = system(commandToRun);
catch err
    ex = MException('distcompexamples:Symphony:FailedToGetJobState', ...
        'Failed to get job state from scheduler.');
    ex.addCause(err);
    throw(ex);
end

if cmdFailed
    warning('distcompexamples:Symphony:FailedToViewSessionStatus', ...
    'Failed to view task status with the following message:\n%sRetrying...', ...
    cmdOut);
end

schedulerState = iExtractJobState(cmdOut, numberOfTasks);
dctSchedulerMessage(6, '%s: State %s was extracted from scheduler output:\n\t%s', currFilename, schedulerState, cmdOut);

% If we could determine the scheduler's state, we'll use that, otherwise
% stick with MATLAB's job state.
if ~strcmp(schedulerState, 'unknown')
    state = schedulerState;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state = iExtractJobState(bjobsOut, numberOfTasks)
% Function to extract the job state from the output of bjobs
% How many PEND
numPendingStr = regexp(bjobsOut, 'PEND: <[0-9]*>', 'once', 'match');
numPending = sscanf(numPendingStr, 'PEND: <%d>');
% How many RUN
numRunningStr = regexp(bjobsOut, 'RUN: <[0-9]*>', 'once', 'match');
numRunning = sscanf(numRunningStr, 'RUN: <%d>');
% How many ERR, CANL
numErrStr = regexp(bjobsOut, 'ERR: <[0-9]*>', 'once', 'match');
numErr = sscanf(numErrStr, 'ERR: <%d>');
numCancelStr = regexp(bjobsOut, 'CANL: <[0-9]*>', 'once', 'match');
numCancel = sscanf(numCancelStr, 'CANL: <%d>');
numFailed = numErr + numCancel;
% How many DONE
numFinishedStr = regexp(bjobsOut, 'DONE: <[0-9]*>', 'once', 'match');
numFinished = sscanf(numFinishedStr, 'DONE: <%d>');

% If the number of finished jobs is the same as the number of jobs that we
% asked about then the entire job has finished.
if numFinished == numberOfTasks
    state = 'finished';
    return;
end

% Any running indicates that the job is running
if numRunning > 0
    state = 'running';
    return
end
% We know numRunning == 0 so if there are some still pending then the
% job must be queued again, even if there are some finished
if numPending > 0
    state = 'queued';
    return
end
% Deal with any tasks that have failed
if numFailed > 0
    % Set this job to be failed
    state = 'failed';
    return
end

state = 'unknown';
