function [Pk,result]=Jacobi_Proximal_ADMM(obj,rho,C)
%输出为 Pk(T×N+1)
gamma=C(1);


%因为要考虑近邻项所以需要设置初值
Pk=zeros(obj.T,obj.N+1);  u=zeros(obj.T,1);

%设置参数
kMax=100;%最大迭代次数
result=zeros(3,kMax); tdt=zeros(1,kMax);
%A_n =1,n=1..N; A_N+1=-1;

%开始迭代
for k=1:kMax
    Pk_1=Pk;
    %并行更新P
tend=zeros(1,obj.N);
    for n=1:obj.N
tstart=cputime;
        Pk(:,n)=argminP(n,u,Pk_1,rho,C(2),obj);
tend(n)=cputime-tstart;
    end
    %Pk_1()
tstart=cputime;
    Pk(:,obj.N+1)=argminP_N1(u,Pk_1,rho,C(3),obj);

    %更新lambda

    u=u+gamma*(sum(Pk(:,1:obj.N),2)-Pk(:,end));
tend(obj.N+1)=cputime-tstart;    
    %计算误差
    result(1,k)=norm(Pk-Pk_1);  
    result(2,k)=uperror(sum(Pk(:,1:obj.N),2)-Pk(:,end));

    result(3,k)=max(tend(1:end-1))+tend(obj.N+1)+tdt(k);
    tdt(k+1)=result(3,k);
    disp(result(:,k))   
end
result=result(:,1:k);%删去非零元素
end


function Pn=argminP(n,u,PnOld,rho,c,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=c*(N-1)*rho;

%电价花费
 f1=obj.ElePrice.'*obj.dt;
%满意度
H2=2*ones(T,T); f2=-2*obj.Ep(n)*ones(T,1);
%0范数
 f4=ones(T,1); %等价于电价约束

Y=-(sum(PnOld(:,1:N),2)-PnOld(:,n))+PnOld(:,end)-u;
[H55,f55]=getHof2norm(Y);

%紧邻项
[H66,f66]=getHof2norm(PnOld(:,n));

H=        W(2)*H2+        rho/2*H55+psi/2*H66;
f=W(1)*f1+W(2)*f2+W(4)*f4+rho/2*f55+psi/2*f66;


A=obj.A([n,obj.N+n],:);
b=obj.b([n,obj.N+n]);
lb=obj.lb(n,:);
ub=obj.ub(n,:);


[Pn] = quadprog(H,f,A,b,[],[],lb,ub);
end
function Pn=argminP_N1(u,PnOld,rho,c,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*rho*c;

%功率稳定
[H3,f3]=getHofVariance(T,obj.BasLoad.');

Y=sum(PnOld(1:N),2)+u;
[H55,f55]=getHof2norm(Y);
%紧邻项

%PnOld(:,end)=sum(PnOld(:,1:obj.N),2);


[H66,f66]=getHof2norm(PnOld(:,end));

H=W(3)*H3+rho/2*H55+psi/2*H66;
f=W(3)*f3+rho/2*f55+psi/2*f66;



[Pn] = quadprog(H,f);
end

