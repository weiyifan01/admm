%������
close all
clear

%���� ģ��糵������ʱ���ʷּ��
N=20;dt=60/60;
A=SmartGrid(N,dt);
%���ø��Ż�Ŀ���Ȩ�� ���ܵ�ѣ��ܲ�����ȣ��������Ч����L0������

A.W=[1,1,1,1];

%ʹ��L0����
A.gg=1;
A.Solve();
A.Show();
B=A.P;

%ʹ��L1����
A.gg=2;
A.Solve();
A.Show();

disp(A.P-B);
