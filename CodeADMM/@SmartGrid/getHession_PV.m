function [H,f]=getHession_PV(obj)
%  format rat
M=obj.T;
N=obj.N;
B=obj.BasLoad;

[H1,f0]=getHofVariance(M,B.');


H=kron(ones(N,N),H1); % ���ԱȻ�����������ⲻ��
%H=kron(H1,ones(N,N));

f=kron(ones(N,1),f0); 
end