function TestMakeAlgoBinary()
% create an algo binary file from 'risk-factor-scenarios.csv'
% file name hardcoded for flexibility reasons
    clear;
    clc;
    
    import prursg.Test.Algo.*;
    % this is a t=0 base scenario with t=2010/12/31
     % skip year 2009 go directly to 2010       
    m = csvread(fullfile('+prursg', '+Algo', '+Data', 'base_t_greater_than_zero.csv'), 2, 3);
    % the USD_fx column must be duplicated! Algo duplicates all FX rates
    m = [ m m(:, end) ];
    
    mout = [];
    for i = 1:size(m, 1)
        mout = [mout m(i, :)]; % there must be a more efficient way to do this
    end
    %
    outFile = AlgoTestsFixture.getAlgoBinaryFileName();
    fileOut = fullfile('outputs', outFile);
    fid = fopen(fileOut, 'w');
    fwrite(fid, mout,'double');
    fclose(fid);
    %
    snifAlgoBinary(outFile);

end

function snifAlgoBinary(fileName)
    fileOut = fullfile('outputs', fileName);
    snifBinary(fileOut, 11);

end

function snifNamanBinary()
    %snif the contents of a binary t=1y file produced by Naman
    snifBinary(fullfile('+prursg', '+Algo', '+Data', 'NAMAN_SCEN_LM_GENERIC.bin'), 11);
end

function snifBinary(fileName, rows)

   fid = fopen(fileName, 'r');
   mydata = fread(fid, 'double');
   fclose(fid);
   %length(mydata)/736   % should give exactly 11
   
   rowSize = length(mydata)/rows;
   m = zeros(rows, rowSize);
   for row = 1:rows
       mrow = mydata((row - 1) * rowSize + 1 : row * rowSize);
       m(row, :) = mrow;
   end
   m; %put a fat breakpoint here to observe
  
end
