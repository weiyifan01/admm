function [Pk]=Jacobi_Proximal_ADMM(obj)
%输出为 Pk(T×N+1)
T=obj.T;
N=obj.N;

obj.rho=0.001;
epsilon_pri=7;% 容许误差

%设置参数
kMax=40;%最大迭代次数
gamma=0.05;
%A_n =1,n=1..N; A_N+1=-1;

%因为要考虑近邻项所以需要设置初值
Pk=zeros(T,N+1);
Pk_1=Pk;
u=zeros(T,1);

%开始迭代
errmesage=zeros(1,kMax);
for k=1:kMax
    %并行更新P
    for n=1:N
        Pk(:,n)=argminP(n,u,Pk_1,obj);
    end
    Pk(:,N+1)=argminP_N1(u,Pk_1,obj);
    
    %更新lambda
    u=u+gamma*(sum(Pk(:,1:N),2)-Pk(:,end));
    
    %计算误差
    err=norm(Pk-Pk_1);
    errmesage(k)=err;
    if err <=epsilon_pri
        break;
    end
    %更新Pk_1
    Pk_1=Pk;
end
disp(errmesage(1:k))
end


function Pn=argminP(n,u,PnOld,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*obj.rho;
%psi=1;

%电价花费
 f1=obj.ElePrice.'*obj.dt;
%满意度
H2=2*ones(T,T); f2=-2*obj.Ep(n)*ones(T,1);
%0范数
 f4=ones(T,1); %等价于电价约束

Y=-(sum(PnOld,2)-PnOld(:,n)-2*PnOld(:,end)+u);
[H55,f55]=getHof2norm(Y);

%紧邻项
[H66,f66]=getHof2norm(PnOld(:,n));

H=        W(2)*H2+        obj.rho/2*H55+psi/2*H66;
f=W(1)*f1+W(2)*f2+W(4)*f4+obj.rho/2*f55+psi/2*f66;


A=obj.A([n,obj.N+n],:);
b=obj.b([n,obj.N+n]);
lb=obj.lb(n,:);
ub=obj.ub(n,:);


[Pn] = quadprog(H,f,A,b,[],[],lb,ub);
end
function Pn=argminP_N1(u,PnOld,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*obj.rho;
%psi=1;

%功率稳定
[H3,f3]=getHofVariance(T,obj.BasLoad.');

Y=sum(PnOld(1:N),2)+u;
[H55,f55]=getHof2norm(Y);
%紧邻项
[H66,f66]=getHof2norm(PnOld(:,end));

H=W(3)*H3+obj.rho/2*H55+psi/2*H66;
f=W(3)*f3+obj.rho/2*f55+psi/2*f66;



[Pn] = quadprog(H,f);
end

