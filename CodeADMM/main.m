%������
close all

A=SmartGrid();

%��������������뿪ʱ��ķֲ�
generate_random_plot(A);

%������ʱ��ۺ;����õ繦�ʷֲ�
PricandLoad(A);


%���Ż����ʷ���Ϊ��
A.W=[1,0,10,0];

%ѡȡ���ʵĲ���
rho=0.01; C=[0.2,1.2,0.05]; 
%gamma=C(1); psi=(obj.N-1)*rho*C(2);psi_N+1+=0.01*(obj.N-1)*rho*C(3);

%ʹ�ö��ADMM ���������˥��ͼ
A.Solve(rho,C);

%���������������ÿ��ʱ�䵥λ�ܵ�ѣ��糵���ʣ��ܹ��ʣ�
%�������⺯����
A.Show();


% �ܻ���Ϊ1447.0891
% ���ʲ�=2.0142
% ���ʷ���=0.55906
% �ܲ������=1333.5401