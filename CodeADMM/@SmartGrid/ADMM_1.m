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


switch obj.gg
    case 1 %ʹ��L0����by fmincon
        f_total_new=W(1)*f1+W(2)*f2 +  W(3)*f3;
        fun = @(X)1/2*X*H_total*X.'+X*f_total_new+sum(X~=0);
        
        options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
        X = fmincon(fun,0*f4.',obj.AA,obj.bb,[],[],obj.LLB,obj.UUB,[],options);
    case 2 %ʹ��L1����by fmincon
        fun = @(X)1/2*X*H_total*X.'+X*f_total;
        
        options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
        X = fmincon(fun,0*f4.',obj.AA,obj.bb,[],[],obj.LLB,obj.UUB,[],options);
        
    case 3  %ʹ��L1����by quadprog       
        X = quadprog(H_total,f_total,obj.AA,obj.bb,[],[],obj.LLB,obj.UUB);
end
end
