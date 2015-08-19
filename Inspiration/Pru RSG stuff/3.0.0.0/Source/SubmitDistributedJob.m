function results = SubmitDistributedJob(taskFunc, numTaskOutputs, taskParams, varargin)
    results = [];
    job = CreateDistributedJob(varargin);
        
    % Create specific number of tasks within the job.
    task = createTask(job, taskFunc, numTaskOutputs, taskParams);

    alltasks = get(job, 'Tasks');
    set(alltasks, 'CaptureCommandWindowOutput', true);

    % Submit the job.
    submit(job);

    % Wait for the job to finish. This client actually checks the job status
    waitForState(job, 'finished');

    outputmessages = get(alltasks, 'CommandWindowOutput');
    disp(outputmessages);

    % If job failed, destroy job and return directly.
    if ~strcmp(job.State, 'finished')
      destroy(job);
      return
    end

    % Job finished, retrieve tasks output
    results = getAllOutputArguments(job);        
    destroy(job);        
    
end

