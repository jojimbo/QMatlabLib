function result = STS_CM(configFlNm)
%% STS_CM
% STS_CM is a so called driver script.
% 
% As Matlab is not able to call a class constructor from a compiled
% executable, this function will be the starting point of the execuable
tic;
result = internalModel.Calculate(configFlNm);

disp('Finished...');
toc
end
