function [H,f]=getHofVariance(T)
%S(P)=(P-\bar{P})^2
%求S(P)的海瑟矩阵 H 及 f
 
%首先计算1/2H
bH_diagonal=zeros(1,T)+(1-1/T)^2+(T-1)*(-1/T)^2;
bH_eles=2*2*(1-1/T)*(-1/T)+(T-2)*2*(-1/T)^2; %交叉项的总系数
bH_eles=bH_eles/2;% 上三角下三角堆成，故除2

%组装为矩阵
bH=ones(T,T)*bH_eles;
bH=diag(bH_diagonal-bH_eles)+bH;

%计算H
H=bH*2;

f=zeros(T,1);

end