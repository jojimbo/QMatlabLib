


Today = datestr(today, 'dd-mmm-yyyy');
Periods = 12;
Dates = daysadd(today,[0:360/Periods:360], 1);
Dates = num2cell(Dates);
Dates = cellfun(@datestr, Dates, 'UniformOutput', false);


[Times, F] = date2time(Today, Dates, 1, 1, 1);
Dates2 = datestr(time2date(Today, Times, 1, 1, 1)); % Sames as Dates

%[TFactors] = cftimes(Settle, Maturity, Period, Basis, EndMonthRule, IssueDate, FirstCouponDate, LastCouponDate, StartDate)

New = quant.instruments.Leg('RECEIVE', Dates);
a = New.DiscountCurve;

DFs = a.getDiscountFactors(daysadd(a.Settle, [0,1,180,360,3600], 1));

