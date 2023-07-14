function [H,f]=getHofVariance(T,B)
%B为列向量

%S(P)=sum{(P+B-\bar{P+B})^2}/T
%求S(P)的海瑟矩阵 H 及 f
 
%首先计算sum{(P-\bar{P})^2}的二次项系数
bH_diagonal=zeros(1,T)+(1-1/T)^2+(T-1)*(-1/T)^2;

%再考虑sum{(P-\bar{P})^2}交叉项的总系数
bH_eles=2*2*(1-1/T)*(-1/T)+(T-2)*2*(-1/T)^2; %类型数*对称项*局部系数

% 上三角下三角对称，故交叉项系数除2
bH_eles=bH_eles/2;

%考虑sum{(P-\bar{P})^2}/T 的系数并组装为矩阵
bH=ones(T,T)*bH_eles/T;
bH=diag(bH_diagonal/T-bH_eles/T)+bH;

%计算H：由H的定义知需乘2
H=bH*2;

%仔细分析可得一次项系数
f=2*(B-sum(B)/T)/T;
end