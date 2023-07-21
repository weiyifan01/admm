function [Pk]=Jacobi_Proximal_ADMM(obj,rho,gamma)
%输出为 Pk(T×N+1)

%因为要考虑近邻项所以需要设置初值
Pk=zeros(obj.T,obj.N+1);  u=zeros(obj.T,1);

%设置参数
kMax=40;%最大迭代次数
err1=zeros(1,kMax);err2=zeros(1,kMax);
%A_n =1,n=1..N; A_N+1=-1;

%开始迭代
for k=1:kMax
    Pk_1=Pk;
    %并行更新P
    for n=1:obj.N
        Pk(:,n)=argminP(n,u,Pk_1,rho,obj);
    end
    Pk(:,obj.N+1)=argminP_N1(u,Pk_1,rho,obj);
    
    %更新lambda

    u=u+gamma*(sum(Pk(:,1:obj.N),2)-Pk(:,end));
    
    %计算误差
    err1(k)=uperror(Pk-Pk_1);
    err2(k)=uperror(sum(Pk(:,1:obj.N),2)-Pk(:,end));
    disp(err1(k))
    if err1(k) < 0.1
        break;
    end
    
end
figure('Name','Reduction of error')
semilogy(1:k,err1(1:k),'b-*',1:k,err2(1:k),'g-o');

end


function Pn=argminP(n,u,PnOld,rho,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*rho;
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

H=        W(2)*H2+        rho/2*H55+psi/2*H66;
f=W(1)*f1+W(2)*f2+W(4)*f4+rho/2*f55+psi/2*f66;


A=obj.A([n,obj.N+n],:);
b=obj.b([n,obj.N+n]);
lb=obj.lb(n,:);
ub=obj.ub(n,:);


[Pn] = quadprog(H,f,A,b,[],[],lb,ub);
end
function Pn=argminP_N1(u,PnOld,rho,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*rho;
%psi=1;

%功率稳定
[H3,f3]=getHofVariance(T,obj.BasLoad.');

Y=sum(PnOld(1:N),2)+u;
[H55,f55]=getHof2norm(Y);
%紧邻项
[H66,f66]=getHof2norm(PnOld(:,end));

H=W(3)*H3+rho/2*H55+psi/2*H66;
f=W(3)*f3+rho/2*f55+psi/2*f66;



[Pn] = quadprog(H,f);
end

