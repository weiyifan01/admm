                                                                            %主函数
close all
clear

%设置 模拟电车数量和时间剖分间隔
N=2;dt=60/60;
A=SmartGri
d(N,dt);
%设置各优化目标的权重 （总电费；总不满意度；削峰填谷效果；L0范数）

A.W=[1,0.2,1,0.01];
%A.W=[0.5,1,10,0.1].*[15/9,1,1,0.11];
%使用L0范数
A.gg=1;
A.Solve();
A.Show();
B=A.P;

%使用L1范数
A.gg=2;
A.Solve();
A.Show();

%disp(A.P-B);
disp('The L-infinity difference with two solutions:');
disp(max(max(A.P-B)));%
