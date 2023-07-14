function [Gamma,SOC]=generate_random(obj)
N=obj.N;
dt=obj.dt;
Pmax=obj.Pmax;
eta=obj.eta;
Cap=obj.Cap;

%计算到达 (1)
muhc=18;
sighc=3.3;

%计算离开 (2)
muhd=8+24;
sighd=3.24;

%第1，2，3列依次代表： 到达时间，期望离开时间，实际离开时间，所属时间层序号
Gamma =zeros(N,2);
SOC=zeros(N,2);
i=1;
while i<=N
    Rc=normrnd(muhc,sighc,1,1);  Gc=ceil(Rc/dt);  %根据正太分布函数生成随机到达和离开时间
    Rd=normrnd(muhd,sighd,1,1);  Gd=ceil(Rd/dt);
    
    bool_1= Gd>Gc; %离开时间晚于到达时间才有意义；
    
    bool_3=Gd-Gc<24;%且充电总时长不能超过一天
    
    S_c= unifrnd(0.1,0.3);  %根据均匀分布函数生成随机初始电量和预期电量
    S_d= unifrnd(0.7,0.9);
    
    bool_2 =(Gd-Gc)*Pmax*dt*eta>=(S_d-S_c)*Cap;  %不考虑紧急情况；
    
    if bool_1 && bool_2 && bool_3
        Gamma(i,1)=Gc;   %大于x的最小整数
        Gamma(i,2)=Gd;
        SOC(i,1)=S_c;
        SOC(i,2)=S_d;
        i=i+1;
    end
end
end