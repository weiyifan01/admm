function [Gamma,SOC]=generate_random(obj)
N=obj.N;
dt=obj.dt;
Pmax=obj.Pmax;
eta=obj.eta;
Cap=obj.Cap;

%���㵽�� (1)
muhc=18;
sighc=3.3;

%�����뿪 (2)
muhd=8+24;
sighd=3.24;

%��1��2��3�����δ��� ����ʱ�䣬�����뿪ʱ�䣬ʵ���뿪ʱ�䣬����ʱ������
Gamma =zeros(N,2);
SOC=zeros(N,2);
i=1;
while i<=N
    Rc=normrnd(muhc,sighc,1,1);  Gc=ceil(Rc/dt);  %������̫�ֲ������������������뿪ʱ��
    Rd=normrnd(muhd,sighd,1,1);  Gd=ceil(Rd/dt);
    
    bool_1= Gd>Gc; %�뿪ʱ�����ڵ���ʱ��������壻
    
    bool_3=Gd-Gc<24;%�ҳ����ʱ�����ܳ���һ��
    
    S_c= unifrnd(0.1,0.3);  %���ݾ��ȷֲ��������������ʼ������Ԥ�ڵ���
    S_d= unifrnd(0.7,0.9);
    
    bool_2 =(Gd-Gc)*Pmax*dt*eta>=(S_d-S_c)*Cap;  %�����ǽ��������
    
    if bool_1 && bool_2 && bool_3
        Gamma(i,1)=Gc;   %����x����С����
        Gamma(i,2)=Gd;
        SOC(i,1)=S_c;
        SOC(i,2)=S_d;
        i=i+1;
    end
end
end