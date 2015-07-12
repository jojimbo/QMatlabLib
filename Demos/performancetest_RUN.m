
len = length(10:1000:100000);
n_sims = zeros(1, len);
times = zeros(1, len);

j=1;
for i=10:1000:100000
    n_sims(j) = i;
    times(j) = performancetest(i);
    j= j+1;
end

