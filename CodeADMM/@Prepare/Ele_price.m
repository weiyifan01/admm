function [Price]=Ele_price(obj)
time=obj.time;
%电价的分段函数
if time <=6
    Price=0.4;
elseif  time <= 8
    Price=0.62;
elseif  time <= 13
    Price = 1.02;
elseif time <= 17
    Price=0.62;
elseif time <=22
    Price = 1.02;
else
    Price=0.7;
end
end