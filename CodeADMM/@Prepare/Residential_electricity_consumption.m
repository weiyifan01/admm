function [Load]=Residential_electricity_consumption(obj)
% 基础荷载的分段函数
time=obj.time;
if time<4
    Load=450;
elseif time<6
    Load=450+(time-4)*100;%650
elseif time<10
    Load=650+(time-6)*12.5;%700
elseif time<12
    Load=700-(time-10)*25; %600
elseif time<16
    Load=650;
elseif time<19
    Load=650+(time-16)*43.33;
else
    Load=780-(time-19)*66;
end
end