                                                                            %������
close all
clear

%���� ģ��糵������ʱ���ʷּ��
N=2;dt=60/60;
A=SmartGri
d(N,dt);
%���ø��Ż�Ŀ���Ȩ�� ���ܵ�ѣ��ܲ�����ȣ��������Ч����L0������

A.W=[1,0.2,1,0.01];
%A.W=[0.5,1,10,0.1].*[15/9,1,1,0.11];
%ʹ��L0����
A.gg=1;
A.Solve();
A.Show();
B=A.P;

%ʹ��L1����
A.gg=2;
A.Solve();
A.Show();

%disp(A.P-B);
disp('The L-infinity difference with two solutions:');
disp(max(max(A.P-B)));%
