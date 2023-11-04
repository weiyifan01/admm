%主函数
close all
clear

%设置 模拟电车数量和时间剖分间隔
N=20;dt=60/60;
A=SmartGrid(N,dt);
%设置各优化目标的权重 （总电费；总不满意度；削峰填谷效果；L0范数）

A.W=[1,1,1,1];

%使用L0范数
A.gg=1;
A.Solve();
A.Show();
B=A.P;

%使用L1范数
A.gg=2;
A.Solve();
A.Show();

disp(A.P-B);
