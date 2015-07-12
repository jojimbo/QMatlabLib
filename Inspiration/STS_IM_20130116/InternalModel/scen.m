function r=scen(k,data)
r=zeros(6,8);

d=data(:,k);

for h=1:48
    i=floor(h/8)+1;
    j=mod(h,8);
    if j==0
        r(i-1,8)=d(h);
    else
        r(i,j)=d(h);
    end
end
r=r';

