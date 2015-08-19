function distributedSubmitFcn(scheduler, job, props, appname, user, passwd, startupFolder)
%DISTRIBUTEDSUBMITFCN Submit a MATLAB job to a Symphony scheduler
%
% Set your scheduler's SubmitFcn to this function using the following
% command:
%     set(sched, 'SubmitFcn', @distributedSubmitFcn);
%
% See also parallel.cluster.generic.distributedDecodeFcn.
%

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2012/01/26 15:05:49GMT $

batch = 500;
decodeFunction = 'parallel.cluster.generic.distributedDecodeFcn';
% Store the current filename for the dctSchedulerMessages
currFilename = mfilename;
if ~scheduler.HasSharedFilesystem
    error('distcompexamples:Symphony:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end
if ~strcmpi(scheduler.ClusterOsType, 'unix')
    error('distcompexamples:Symphony:SubmitFcnError', ...
        'The submit function %s only supports clusters with unix OS.', currFilename)
end
if strcmpi(scheduler.ClusterMatlabRoot,'')
    error('distcompexamples:Symphony:SubmitFcnError', ...
        'The submit function %s must assign a valid clusterMatlabRoot parameter.', currFilename)
end

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(props.MatlabArguments);
variables = {'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor; ...
    'MDCE_JOB_LOCATION', props.JobLocation; ...
    'MDCE_DEBUG', 'true'; ...
    'MDCE_STORAGE_LOCATION', props.StorageLocation};
% Set the required environment variables
for ii = 1:size(variables, 1)
    setenv(variables{ii,1}, variables{ii,2});
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


% Get the tasks for use in the loop
numberOfTasks = props.NumberOfTasks;
ssnID = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% setting default value for 
%% appname, user and passwd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(appname, '')
    appname = 'symexec5.0';
end
if strcmp(user, '')
    user = 'Guest';
end
if strcmp(passwd, '')
    passwd = 'Guest';
end

taskLocations = '';
dctSchedulerMessage(5, '%s: Generating command for session', currFilename);
commandToRun = sprintf('%s create -a %s -u %s -x %s', proxyCmd, appname, user, passwd);

% Now ask the cluster to create session command
dctSchedulerMessage(4, '%s: Create a session to send tasks:\n\t%s', currFilename, commandToRun);
try
    % Make the shelled out call to run the command.
    [cmdFailed, cmdOut] = system(commandToRun);
catch err
    cmdFailed = true;
    cmdOut = err.message;
end
if cmdFailed
    error('distcompexamples:Symphony:CreateSessionFailed', ...
        'Create session failed with the following message:\n%s', cmdOut);
end

ssnID = extractJobId(cmdOut);
if ~ssnID
    error('distcompexamples:Symphony:FailedToParseCreateSessionOutput', ...
        'Failed to parse the session identifier from the create session output: "%s"', ...
        cmdOut);
end

% set the session ID on the job scheduler data
scheduler.setJobSchedulerData(job, struct('SchedulerAppName', appname, 'SchedulerAppUser', user, 'SchedulerAppPasswd', passwd, 'SchedulerSsnID', ssnID, 'SchedulerTasksNumber', numberOfTasks));

% Loop over every task we have been asked to submit
for ii = 1:numberOfTasks
    taskLocation = props.TaskLocations{ii};

    if mod(ii, batch) && (ii ~= numberOfTasks)
      taskLocations = [taskLocations, taskLocation];
      taskLocations = [taskLocations, ':'];
      continue;
    end

    taskLocations = [taskLocations, taskLocation];
    % Set the environment variable that defines the location of this task
    setenv('MDCE_TASK_LOCATIONS', taskLocations);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CUSTOMIZATION /EXECcMD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % You may also with to supply additional submission arguments to 
    % the mlproxy command here.
    cmd = [sprintf('/bin/sh -c "cd %s', startupFolder) ' && exec ' props.MatlabExecutable '"' ];
    commandToRun = getSubmitString(proxyCmd, ssnID, appname, ...
        user, passwd, cmd, matlabArguments);

    % Now ask the cluster to run the submission command
    dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
    try
        % Make the shelled out call to run the command.
        [cmdFailed, cmdOut] = system(commandToRun);
    catch err
        cmdFailed = true;
        cmdOut = err.message;
    end
    if cmdFailed
        error('distcompexamples:Symphony:SubmissionFailed', ...
            'Submit failed with the following message:\n%s', cmdOut);
    end

    taskLocations = '';
    dctSchedulerMessage(1, '%s: Submission output: %s\n', currFilename, cmdOut);
end
