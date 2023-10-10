function [Load]=Residential_electricity_consumption(obj)
% 基础荷载的分段函数
time=obj.time;
if time<4
    Load=450;
elseif time<6
    Load=450+(time-4)*75;
elseif time<20
    Load=600;
else
    Load=600-(time-20)*37.5;
end
end