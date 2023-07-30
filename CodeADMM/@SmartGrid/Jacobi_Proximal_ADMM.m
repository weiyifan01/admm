function [Pk]=Jacobi_Proximal_ADMM(obj,rho,psi)
%���Ϊ Pk(T��N+1)
gamma=1;


%��ΪҪ���ǽ�����������Ҫ���ó�ֵ
Pk=zeros(obj.T,obj.N+1);  u=zeros(obj.T,1);

%���ò���
kMax=100;%����������
err1=zeros(1,kMax);err2=zeros(1,kMax);
%A_n =1,n=1..N; A_N+1=-1;

%��ʼ����
for k=1:kMax
    Pk_1=Pk;
    %���и���P
    for n=1:obj.N
        Pk(:,n)=argminP(n,u,Pk_1,rho,psi,obj);
    end
    %Pk_1()
    Pk(:,obj.N+1)=argminP_N1(u,Pk_1,rho,psi,obj);
    
    %����lambda

    u=u+gamma*(sum(Pk(:,1:obj.N),2)-Pk(:,end));
    
    %�������
    err1(k)=uperror(Pk-Pk_1);
    err2(k)=uperror(sum(Pk(:,1:obj.N),2)-Pk(:,end));
    disp(max(abs(sum(Pk(:,1:obj.N),2)-Pk(:,end))))

%     if  err1(k)<1
%         break;
%     end
%     if k>=10
%     if  err2(k)>err2(k-1)
%         Pk=Pk_1;
%         break;
%     end
%     end
    
end
figure('Name','Reduction of error')
semilogy(1:k,err1(1:k),'b-*',1:k,err2(1:k),'g-o');
TT=strcat('rho=',num2str(rho),'psi=',num2str((obj.N-1)*rho),'gamma=',num2str(gamma));title(TT);

end


function Pn=argminP(n,u,PnOld,rho,psi,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*rho;

%��ۻ���
 f1=obj.ElePrice.'*obj.dt;
%�����
H2=2*ones(T,T); f2=-2*obj.Ep(n)*ones(T,1);
%0����
 f4=ones(T,1); %�ȼ��ڵ��Լ��

Y=-(sum(PnOld(:,1:N),2)-PnOld(:,n))+PnOld(:,end)-u;
[H55,f55]=getHof2norm(Y);

%������
[H66,f66]=getHof2norm(PnOld(:,n));

H=        10*W(2)*H2+        rho/2*H55+psi/2*H66;
f=W(1)*f1+10*W(2)*f2+10*W(4)*f4+rho/2*f55+psi/2*f66;


A=obj.A([n,obj.N+n],:);
b=obj.b([n,obj.N+n]);
lb=obj.lb(n,:);
ub=obj.ub(n,:);


[Pn] = quadprog(H,f,A,b,[],[],lb,ub);
end
function Pn=argminP_N1(u,PnOld,rho,psi,obj)
W=obj.W;
T=obj.T;
N=obj.N;
psi=(N-1)*rho*0.01;

%�����ȶ�
[H3,f3]=getHofVariance(T,obj.BasLoad.');

Y=sum(PnOld(1:N),2)+u;
[H55,f55]=getHof2norm(Y);
%������

PnOld(:,end)=sum(PnOld(:,1:obj.N),2);


[H66,f66]=getHof2norm(PnOld(:,end));

H=100*W(3)*H3+rho/2*H55+psi/2*H66;
f=100*W(3)*f3+rho/2*f55+psi/2*f66;



[Pn] = quadprog(H,f);
end

