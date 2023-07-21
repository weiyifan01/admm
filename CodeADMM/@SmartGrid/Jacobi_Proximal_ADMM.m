function [Pk]=Jacobi_Proximal_ADMM(obj,rho,gamma)
%���Ϊ Pk(T��N+1)
%��ΪҪ���ǽ�����������Ҫ���ó�ֵ
Pk=zeros(obj.T,obj.N+1);  u=zeros(obj.T,1);

%���ò���
kMax=40;%����������
err1=zeros(1,kMax);err2=zeros(1,kMax);
%A_n =1,n=1..N; A_N+1=-1;

%��ʼ����
for k=1:kMax
    Pk_1=Pk;
    %���и���P
    for n=1:obj.N
        Pk(:,n)=argminP(n,u,Pk_1,rho,obj);
    end
    Pk(:,obj.N+1)=argminP_N1(u,Pk_1,rho,obj);
    
    %����lambda
    u=u+gamma*(sum(Pk(:,1:obj.N),2)-Pk(:,end));
    
    %�������
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

%��ۻ���
 f1=obj.ElePrice.'*obj.dt;
%�����
H2=2*ones(T,T); f2=-2*obj.Ep(n)*ones(T,1);
%0����
 f4=ones(T,1); %�ȼ��ڵ��Լ��

Y=-(sum(PnOld,2)-PnOld(:,n)-2*PnOld(:,end)+u);
[H55,f55]=getHof2norm(Y);

%������
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

%�����ȶ�
[H3,f3]=getHofVariance(T,obj.BasLoad.');

Y=sum(PnOld(1:N),2)+u;
[H55,f55]=getHof2norm(Y);
%������
[H66,f66]=getHof2norm(PnOld(:,end));

H=W(3)*H3+rho/2*H55+psi/2*H66;
f=W(3)*f3+rho/2*f55+psi/2*f66;



[Pn] = quadprog(H,f);
end

