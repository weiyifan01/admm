%主函数
close all

A=SmartGrid();

%画出车辆到达和离开时间的分布
generate_random_plot(A);

%画出分时电价和居民用电功率分布
PricandLoad(A);


%以优化功率方差为例
A.W=[0,0,10,0];

%选取合适的参数
rho=0.01; C=[0.5,1,1]; 
%gamma=C(1); psi=(obj.N-1)*rho*C(2);psi_N+1+=0.01*(obj.N-1)*rho*C(3);

%使用多块ADMM 并计算误差衰减图
A.Solve(rho,C);

%画出结果（包括：每个时间单位总电费，电车功率，总功率）
%画出满意函数，
A.Show();