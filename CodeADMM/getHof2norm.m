function [H,f]=getHof2norm(Y)
%f(X)=(X-Y)^2
%��f(X)�ĺ�ɪ���� H �� f

T=length(Y);
 
%���ȼ���1/2*H
bH= diag(ones(1,T));

%����H
H=bH*2;

f=-2*Y;
end