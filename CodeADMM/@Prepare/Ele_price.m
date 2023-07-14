function [Price]=Ele_price(obj)
time=obj.time;
%Fig 3
if time <=6
    Price=0.4;
elseif  time <= 8
    Price=0.7;
elseif  time <= 13
    Price = 1.2;
elseif time <= 17
    Price=0.7;
elseif time <=22
    Price = 1.2;
else
    Price=0.7;
end
end