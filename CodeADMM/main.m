%������
close all
clear

%���� ģ��糵������ʱ���ʷּ��
if 1==1
    N=200;dt=15/60;
    A=SmartGrid(N,dt);
end

if 1==2 %�Ƿ�ͼ
    generate_random_plot(A);   %��������������뿪ʱ��ķֲ�
    PricandLoad(A);            %������ʱ��ۺ;����õ繦�ʷֲ�
end

%���ø��Ż�Ŀ���Ȩ�� ���ܵ�ѣ��ܲ�����ȣ��������Ч����L0������
A.W=[0.5,1,10,0].*[15/9,1,1,0];


% ����һ========================================================================================================
if 1==2
    tic
    A.Solve();
    toc;
    A.Show();
end

%Jacobi_Proximal����===========================================================================================
if 1==2
    %�������˥�������
    rho=0.1; C=[1.5,2,0.01];  %ѡ�����ʵĲ���
    A.RHO_c=rho;A.C_c=C;
    %rho=(0.01-0.05) C=[(0.1-1.5)   (0--2)  (0-0)]
    %gamma=C(1); psi=(obj.N-1)*rho*C(2);psi_N+1+=0.01*(obj.N-1)*rho*C(3);
    A.Solve(rho,C);
    
    A.ShowIteration();
    %�洢���
    if A.W(3)==0
        str0='noXue';
    else
        str0=num2str(A.W(3));
    end
    TT=strcat('result\Jac_Pro_',str0,'.mat');
    save(TT,'A')
end


%����ADMM����==================================================================================================
if 1==1
    rho=5; %ѡȡ���ʵĲ���    
    A.RHO_c=rho;
    
    A.Solve(rho);
    %�洢���
    if A.W(3)==0
        str0='noXue';
    else
        str0=num2str(A.W(3));
    end
    TT=strcat('result\ADMM2_',str0,'.mat');
    save(TT,'A')
end


%���������������ÿ��ʱ�䵥λ�ܵ�ѣ��糵���ʣ��ܹ��ʣ�
A.Show();
A.ShowIteration();
