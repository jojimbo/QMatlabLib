function sample()

% The scheduler type prefixed with "generic" represents a generic scheduler
sched = findResource('scheduler', 'type', 'generic');

% Specify the data location where the job and task data will be generated
% and where the task evaluation script file is put.
dataLocation='/nfs/lldnfs01v/matlab/job_data/llwsolv106';
set(sched, 'DataLocation', dataLocation);

% It is mandatory to specify using shared file system and matlab install root 
% for generic scheduler.
set(sched, 'HasSharedFilesystem', true);
set(sched, 'ClusterMatlabRoot', '/nfs/lldnfs01v/matlab/MATLAB');

% Specify the Symphony-MATLAB integration functions
set(sched, 'SubmitFcn', {@distributedSubmitFcn, 'symexec5.0', 'wasadmin', 'PGDS_WAS', pwd});
set(sched, 'GetJobStateFcn', @getJobStateFcn);
set(sched, 'DestroyJobFcn', @destroyJobFcn);

% Create a MATLAB job. The job data will be generated into the data
% location.
job = createJob(sched);
set(job, 'PathDependencies', {fullfile(pwd)});

% Create specific number of tasks within the job.
createTask(job, @tt, 1, {});


alltasks = get(job, 'Tasks');
set(alltasks, 'CaptureCommandWindowOutput', true);

% Submit the job.
submit(job);

% Wait for the job to finish. This client actually checks the job status
waitForState(job, 'finished');

outputmessages = get(alltasks, 'CommandWindowOutput')

% If job failed, destroy job and return directly.
if ~strcmp(job.State, 'finished')
  destroy(job);
  return
end

% Job finished, retrieve tasks output
results = getAllOutputArguments(job);
for i = 1:3
  %disp(results{i});
end

destroy(job);

end

function t = tt()    
    t = 1;
    pwd
%     %javaclasspath
%      cd('./ValReports')
%      %pwd
%      delete('./base/*.*');
%      rmdir('./base');
%      cd('../PruFiles')
%      delete('./base/*.*');
%      rmdir('./base');
%      cd('../AlgoFiles')
%      delete('./base/*.*');
%      rmdir('./base');
%      
     cd ('./Deploy');
     pwd
%     %javaclasspath
     cd('./ValReports')
     %pwd
     delete('./base/*.*');
     rmdir('./base');
     cd('../PruFiles')
     delete('./base/*.*');
     rmdir('./base');
     cd('../AlgoFiles')
     delete('./base/*.*');
     rmdir('./base');
end