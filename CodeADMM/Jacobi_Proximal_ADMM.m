function [Pk]=Jacobi_Proximal_ADMM(N,T)
%���ò���
kMax=100;%����������
epsilon_pri=1e-3;% �������
rho=0.01;
gamma=1;
%A_n =1,n=1..N; A_N+1=-1;


%���ó�ֵ
Pk=zeros(T,N+1);
Pk_1=Pk;
Lambda=zeros(T,1);

%��ʼ����
for k=1:kMax
    %���и���P
    for n=1:N+1
      Pk(:,n)=argminP(n,Lambda,rho,Pk_1(:,n));
    end
    
    %����lambda
    Lambda=Lambda-gamma*rho*(sum(Pk(:,1:N),2)-Pk(:,end));
   
    %�������
    err=norm(Pk-Pk_1);
    if err <=epsilon_pri
        break;
    end
    %����Pk_1
    Pk_1=Pk;
end
end