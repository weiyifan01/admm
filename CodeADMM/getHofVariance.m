function [H,f]=getHofVariance(T,B)
%BΪ������

%S(P)=sum{(P+B-\bar{P+B})^2}/T
%��S(P)�ĺ�ɪ���� H �� f
 
%���ȼ���sum{(P-\bar{P})^2}�Ķ�����ϵ��
bH_diagonal=zeros(1,T)+(1-1/T)^2+(T-1)*(-1/T)^2;

%�ٿ���sum{(P-\bar{P})^2}���������ϵ��
bH_eles=2*2*(1-1/T)*(-1/T)+(T-2)*2*(-1/T)^2; %������*�Գ���*�ֲ�ϵ��

% �����������ǶԳƣ��ʽ�����ϵ����2
bH_eles=bH_eles/2;

%����sum{(P-\bar{P})^2}/T ��ϵ������װΪ����
bH=ones(T,T)*bH_eles/T;
bH=diag(bH_diagonal/T-bH_eles/T)+bH;

%����H����H�Ķ���֪���2
H=bH*2;

%��ϸ�����ɵ�һ����ϵ��
f=2*(B-sum(B)/T)/T;
end