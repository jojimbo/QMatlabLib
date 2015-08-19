function job = CreateDistributedJob(varargin)    
    schedulerType = prursg.Util.ConfigurationUtil.GetSchedulerType();
    if ~prursg.Util.ConfigurationUtil.GetUseGrid()
        schedulerType = 'local';
    end
    scheduler = findResource('scheduler', 'type', schedulerType);   
    if ~isempty(scheduler)
        set(scheduler, 'ClusterMatlabRoot', prursg.Util.ConfigurationUtil.GetClusterMatlabRoot());
        set(scheduler, 'DataLocation', prursg.Util.ConfigurationUtil.GetDataLocation());
        set(scheduler, 'HasSharedFilesystem', true);
        
        if strcmpi(schedulerType, 'generic')
            % Specify the Symphony-MATLAB integration functions
            appName = prursg.Util.ConfigurationUtil.GetSymphonyAppName();
            if ~isempty(varargin)
                if iscell(varargin{1})
                    appName = varargin{1}{1};
                else
                    appName = varargin{1};
                end
            end            
            set(scheduler, 'SubmitFcn', {@distributedSubmitFcn, appName, prursg.Util.ConfigurationUtil.GetSymphonyUserId(), prursg.Util.ConfigurationUtil.GetSymphonyPassword(), prursg.Util.ConfigurationUtil.GetRootFolderPath()});            
            set(scheduler, 'GetJobStateFcn', @getJobStateFcn);
            set(scheduler, 'DestroyJobFcn', @destroyJobFcn);
        end
        
        % Create a MATLAB job. The job data will be generated into the data
        % location.
        job = createJob(scheduler);
        if isdeployed
            set(job, 'PathDependencies', {fullfile(ctfroot, 'RSGSimulate')});
            set(job, 'JobData', get(job, 'PathDependencies'));
        else
            set(job, 'PathDependencies', {fullfile(pwd)});    
        end         
        disp('Path Dependencies-');
        disp(get(job, 'PathDependencies'));
    else
        ex = MException('CreateDistributedJob', 'Cannot find a scheduler for the given scheduler type %s', schedulerType);
        throw(ex);
    end
end

