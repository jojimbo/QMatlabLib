function res = adjustTimesForLeapYear(ev,times)

%vector of dates based on times
 t = ev + times;
 
 %maturity date
 T = t(numel(t));
 
 res = times;
 
 %the adjustment consists in subtracting all the 29th Feb between each date
 % and maturity
 
 for i = 1: numel(times)
     res(i) = times(i) - count29Feb(t(i),T);
 end