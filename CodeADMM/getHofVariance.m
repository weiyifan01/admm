function [H,f]=getHofVariance(T)
%S(P)=(P-\bar{P})^2
%��S(P)�ĺ�ɪ���� H �� f
 
%���ȼ���1/2H
bH_diagonal=zeros(1,T)+(1-1/T)^2+(T-1)*(-1/T)^2;
bH_eles=2*2*(1-1/T)*(-1/T)+(T-2)*2*(-1/T)^2; %���������ϵ��
bH_eles=bH_eles/2;% �����������Ƕѳɣ��ʳ�2

%��װΪ����
bH=ones(T,T)*bH_eles;
bH=diag(bH_diagonal-bH_eles)+bH;

%����H
H=bH*2;

f=zeros(T,1);

end