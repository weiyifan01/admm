%主函数
close all

A=SmartGrid();

%画出车辆到达和离开时间的分布
generate_random_plot(A);

%画出分时电价和居民用电功率分布
PricandLoad(A);


%以优化功率方差为例
A.W=[1,1,1,0.1];

%选取合适的参数
rho=1*1/A.N; C=[1.5,2,0];  %gamma, psi1, psi2

%rho=(0.01-0.05) C=[(0.1-1.5)   (0--2)  (0-0)]
%gamma=C(1); psi=(obj.N-1)*rho*C(2);psi_N+1+=0.01*(obj.N-1)*rho*C(3);

%使用多块ADMM 并计算误差衰减图
 A.Solve(rho,C);
% A.Solve(rho);

%画出结果（包括：每个时间单位总电费，电车功率，总功率）
%画出满意函数，
A.Show();


% 总花费为1447.0891
% 功率差=2.0142
% 功率方差=0.55906
% 总不满意度=1333.5401