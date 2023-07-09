function [Pk]=Jacobi_Proximal_ADMM(N,T)
%设置参数
kMax=100;%最大迭代次数
epsilon_pri=1e-3;% 容许误差
rho=0.01;
gamma=1;
%A_n =1,n=1..N; A_N+1=-1;


%设置初值
Pk=zeros(T,N+1);
Pk_1=Pk;
Lambda=zeros(T,1);

%开始迭代
for k=1:kMax
    %并行更新P
    for n=1:N+1
      Pk(:,n)=argminP(n,Lambda,rho,Pk_1(:,n));
    end
    
    %更新lambda
    Lambda=Lambda-gamma*rho*(sum(Pk(:,1:N),2)-Pk(:,end));
   
    %计算误差
    err=norm(Pk-Pk_1);
    if err <=epsilon_pri
        break;
    end
    %更新Pk_1
    Pk_1=Pk;
end
end