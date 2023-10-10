function [X]=ADMM_1(obj)
W=obj.W;
%%
%%
%׷�󻨷����
%H1=spares(obj.N*obj.T,obj.N*obj.T);
f1=repmat((obj.ElePrice*obj.dt).',obj.N,1);
%f1=getHession_ct(obj);
%%
%׷�����ȶ�
[H3,f3]=getHession_PV(obj);
%%
%׷���û������⣨SOC�ﵽ0.9��
[H2,f2]=getHession_sa(obj);

%0���� %�ȼ�����Լ��
f4= kron(ones(obj.T,1),ones(obj.N,1));


%%
%����Ȩ��
H_total=        W(2)*H2 +  W(3)*H3;
f_total=W(1)*f1+W(2)*f2 +  W(3)*f3 +W(4)*f4;

X = quadprog(H_total,f_total,obj.AA,obj.bb,[],[],obj.LLB,obj.UUB);
end
