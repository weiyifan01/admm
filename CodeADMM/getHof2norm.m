function [H,f]=getHof2norm(Y)
%f(X)=(X-Y)^2
%求f(X)的海瑟矩阵 H 及 f

T=length(Y);
 
%首先计算1/2*H
bH= diag(ones(1,T));

%计算H
H=bH*2;

f=-2*Y;
end