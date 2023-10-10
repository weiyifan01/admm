%主函数
close all
clear

%设置 模拟电车数量和时间剖分间隔
N=200;dt=15/60;
A=SmartGrid(N,dt);

if 1==0 %是否画图
    generate_random_plot(A);   %画出车辆到达和离开时间的分布
    PricandLoad(A);            %画出分时电价和居民用电功率分布
end

%设置各优化目标的权重 （总电费；总不满意度；削峰填谷效果；L0范数）
% A.W=[0.5,1,20,1];
A.W=[1,1,10,0].*[15/9,1,1,0];


% 方法一========================================================================================================
if 1==2
    tic
    A.Solve();
    toc;
    A.Show();
end

%Jacobi_Proximal方法===========================================================================================
if 1==2
    %计算误差衰减速情况
    rho=0.1; C=[1.5,2,0.01];  %选定合适的参数
    %rho=(0.01-0.05) C=[(0.1-1.5)   (0--2)  (0-0)]
    %gamma=C(1); psi=(obj.N-1)*rho*C(2);psi_N+1+=0.01*(obj.N-1)*rho*C(3);
    A.Solve(rho,C);
       
    A.ShowIteration();
    save('result\Re1_no.mat','A')
end


%两块ADMM方法==================================================================================================
rho=5; %选取合适的参数
A.Solve(rho);
save('result\Re2.mat','A')

%画出结果（包括：每个时间单位总电费，电车功率，总功率）
% A.Show();
A.ShowIteration();
