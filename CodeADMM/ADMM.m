function [Pk1,Yk1]=ADMM()
%设置参数
N=100;%最大迭代次数
epsilon_pri=1e-3;% 容许误差
epsilon_dual=1e-4;% 容许误差
rho=0.1;
zta=1;


%设置初值
Pk=0;
Yk=0;
muk=0;

%开始迭代
bool0=1;
while k<=N&&bool0
    %并行
    Pk1=argminP_Phi(Pk,Yk,muk);
    Yk1=argminY_Psi(Pk,Yk,muk);
    
    muk=muk-zta*rho*(Pk1-Yk1); 
    
    err_r=norm(Pk1-Yk1);
    err_s=norm(rho*(Yk1-Yk));
    
    bool0= (err_r>=epsilon_pri)||(err_s>epsilon_dual);
end
end