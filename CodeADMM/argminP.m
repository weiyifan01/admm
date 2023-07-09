function Pn=argminP(n,Lambda,rho,PnOld)
E=0;%? ‰»ÎµÁº€
dt=0;%?


T=length(Lambda);
if n==N+1
    H1=[];f1=E*dt;
    
    H2=2*eye(T); f2=-2*Gamman*ones(T,1);
    
    H3=[]; f3=ones(T,1);
    
    Y=sum(PnOld,2)-PnOld(:,n)-PnOld(:,end)-Lambda/rho;
    [H4,f4]=getHof2norm(Y);
    
    [H5,f5]=getHof2norm(PnOld(:,n));
    
    H=H1+H2+H3+rho/2*H4+psi/2*H5;
    f=f1+f2+f3+rho/2*f4+psi/2*f5;
else
    
    [H1,f1]=getHofVariance(T);
    
    Y=sum(PnOld,2)-PnOld(:,end)-Lambda/rho;
    [H4,f4]=getHof2norm(Y);
    
    [H5,f5]=getHof2norm(PnOld(:,N+1));
    
    H=H1+rho/2*H4+psi/2*H5;
    f=f1+rho/2*f4+psi/2*f5;
end

lb=0;
ub=18;

[Pn] = quadprog(H,f,[],[],[],[],lb,ub,[],options);
end


