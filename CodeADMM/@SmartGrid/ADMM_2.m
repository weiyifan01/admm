%ADMM算法

%拉格朗日函数
%L(P1,P2,lambda)=Satisfy(P1)+PV(P1)+lambda^T(P1-P2)

%带惩罚项  拉格朗日函数
%L(P1,P2,lambda)=Satisfy(P1)+PV(P1)+lambda^T(P1-P2)+rho/2*(P1-P2)^2

function [X]=ADMM_2(obj,rho)
% rho =1;

P2=zeros(obj.T*obj.N,1);P1=zeros(obj.T*obj.N,1);lambda=zeros(obj.T*obj.N,1);

kMax=10; err1=zeros(1,kMax);err2=zeros(1,kMax);
for k=1:kMax

    Pold=P1;
    P1=argminP1_Lrho(P2,lambda,rho,obj);
    P2=argminP2_Lrho(P1,lambda,rho,obj);
    
    lambda=lambda+(P1-P2);
    
    err1(k)=norm(P1-Pold);
    err2(k)=norm(P1-P2);
    disp([err1(k),err2(k),k])
    if err1(k)+err2(k) < 1
        break;
    end
end

semilogy(1:k,err1(1:k),'b-*',1:k,err2(1:k),'g-o');
X=P1;
end


function [X]=argminP1_Lrho(P2,lambda,rho,obj)
W=obj.W.*[15/9,1,1,1];

%罚项 和 拉格朗日
[H0,f0]=getHof2norm(P2-lambda);

%追求花费最低
%H1=spares(obj.N*obj.T,obj.N*obj.T);
f1=repmat((obj.ElePrice*obj.dt).',obj.N,1);

%用户满意
[H2,f2]=getHession_sa(obj);


H=rho/2*H0+W(2)*H2;
f=rho/2*f0+W(2)*f2 + W(1)*f1;

X = quadprog(H,f,obj.AA,obj.bb,[],[],obj.LLB,obj.UUB);
end

function [X]=argminP2_Lrho(P1,lambda,rho,obj)
W=obj.W.*[15/9,1,1,1];

%罚项 和 拉格朗日
[H0,f0]=getHof2norm(P1+lambda);

%追求功率稳定
[H3,f3]=getHession_PV(obj);

H=rho/2*H0+W(3)*H3;
f=rho/2*f0+W(3)*f3;

X = quadprog(H,f,obj.AA,obj.bb,[],[],obj.LLB,obj.UUB);
end