%% Bootstrap Validation - RSGBootstrapValidate
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *Description*
%
% This function is the entry point for the bootstrap validation process. It
% instantiates the Bootstrap Validation engine and calls the
% BootstrapValidate method passing the input XML control file as an input
% parameter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OutputFilesPath = RSGBootstrapValidate(xmlFilePath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input parameters
%                 
% |xmlFilePath| - string, a fully qualified path pointing to the input 
% control XML file for the bootstrap validation process
%
%% Output parameters
%
% |Outputfiles| - string, a fully qualified path pointing to the output
% folder where the intermediate file containing the validation results will
% be saved
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %error('The RSGBootstrapValidate method is not supported in this release');
    
	fprintf('RSGBootstrapValidate method has started... \n');
    
    fprintf('Initializing the Bootstrap Validation engine... \n'); 
    % Initialize the Bootstrap Validation engine
    bootstrapValidationEngine = prursg.BootstrapValidation.BootstrapValidationEngine();
    fprintf('Bootstrap Validation engine has been initialized successfully... \n'); 
    
    fprintf('Calling the BootstrapValidate method... \n'); 
    % Call the BootstrapValidate function
    OutputFilesPath = bootstrapValidationEngine.BootstrapValidate(xmlFilePath);  
    fprintf('Exiting BootstrapValidate method... \n');
    
    fprintf('RSGBootstrapValidate method has completed successfully... \n');
    
    pctRunDeployedCleanup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

