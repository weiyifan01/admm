classdef SmartGrid < Prepare
    %此类用于设置参数；调用解决方案；展示解决方案
    
    properties
        P; %N行T列 由P_{n,t}组成的矩阵
       
        W=[1,1,1,1]; %各个目标函数的权重 [总电费；不满意度；功率稳定；L0充电时长
        
        AA;  % 线性约束
        bb;  % 线性约束
        UUB; % 上界
        LLB; % 下界
        result; % 存储迭代结果
    end
    
    methods
        function obj = SmartGrid(N,dt)
            % 通过运行Prepare来初始化
            obj =  obj@Prepare(N,dt);
        end
        

        function Solve(obj,rho,gamma) %选择不同的求解方案 
            switch nargin
                case 1 %整合为一个二次优化问题，一步到位
                    Ablbub(obj,1) %整理对应的约束条件
                    Xv=ADMM_1(obj);
                    obj.P=reshape(Xv,obj.T,obj.N).'; %将结果重构为矩阵型
                case 2 %两块的ADMM
                    Ablbub(obj,2)%整理对应的约束条件
                    Xv=ADMM_2(obj,rho);
                    obj.P=reshape(Xv,obj.T,obj.N).';
                case 3 %N+1块的ADMM，且可并行处理
                    Ablbub(obj,3)%整理对应的约束条件
                    [Pk,result0]=Jacobi_Proximal_ADMM(obj,rho,gamma); %Pk(T×N+1)
                    obj.P=Pk(:,1:end-1).'; %舍去最后一行的 求和行
                    obj.result=result0;
            end
        end
        
        
       
        
        
        %添加约束条件
        function Ablbub(obj,k)
            switch k
                case {1,2}
                    obj.AA=sparse(2*obj.N,obj.T*obj.N);
                    kk=0;
                    for k=1:obj.N
                        kk=kk+1;
                        obj.AA(kk,1+(k-1)*obj.T:k*obj.T)=obj.A(kk,:);
                        obj.bb(kk)=obj.b(kk,:);
                    end
                    %不能低于最低期望
                    for k=1:obj.N
                        kk=kk+1;
                        obj.AA(kk,1+(k-1)*obj.T:k*obj.T)=obj.A(kk,:);
                        obj.bb(kk)=obj.b(kk,:);
                    end
                    obj.LLB=reshape(obj.lb.',[],1);  %未到达和离开后 充电状态为0   %参见论文(22)， （23）式
                    obj.UUB=reshape(obj.ub.',[],1); %快充充满即走，所以电量恒满足约束  %参见论文(25)式
                case 3
                    obj.AA=obj.A;
                    obj.bb=obj.b;
                    obj.LLB=obj.lb;
                    obj.UUB=obj.ub;
            end
            
        end
        
        
    end
end

