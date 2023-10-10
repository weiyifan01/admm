function [X]=ADMM_1(obj)
W=obj.W;
%%
%%
%追求花费最低
%H1=spares(obj.N*obj.T,obj.N*obj.T);
f1=repmat((obj.ElePrice*obj.dt).',obj.N,1);
%f1=getHession_ct(obj);
%%
%追求功率稳定
[H3,f3]=getHession_PV(obj);
%%
%追求用户最满意（SOC达到0.9）
[H2,f2]=getHession_sa(obj);

%0范数 %等价与电价约束
f4= kron(ones(obj.T,1),ones(obj.N,1));


%%
%分配权重
H_total=        W(2)*H2 +  W(3)*H3;
f_total=W(1)*f1+W(2)*f2 +  W(3)*f3 +W(4)*f4;

X = quadprog(H_total,f_total,obj.AA,obj.bb,[],[],obj.LLB,obj.UUB);
end
