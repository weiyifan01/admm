classdef SmartGrid < Prepare
    %此类用于设置参数；调用解决方案；展示解决方案
    
    properties
        P; %N行T列 由P_{n,t}组成的矩阵
       
        W=[1,1,1,1]; %各个目标函数的权重 [总电费；不满意度；功率稳定；L0充电时长
        
        AA;  % 线性约束
        bb;  % 线性约束
        UUB; % 上界
        LLB; % 下界
    end
    
    methods
        function obj = SmartGrid()
            % 通过运行Prepare来初始化
            obj =  obj@Prepare();
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
                    [Pk]=Jacobi_Proximal_ADMM(obj,rho,gamma); %Pk(T×N+1)
                    obj.P=Pk(:,1:end-1).'; %舍去最后一行的 求和行
            end
            memory
        end
        
        
        function Show(obj) %对结果进行展示
            %将变量P转化为合适的形状，方便运算
            %向量形式：
            Xv=reshape(obj.P.',[],1);    %逆过程: Xm=reshape(Xv,obj.T,obj.N).';        
            %矩阵形式：
            Xm=obj.P;
            
            %展示总电费=====================================================
            
            CC=obj.ElePrice*obj.dt;
            %每阶段花费
            Cost=sum(Xm.*CC,1);%1对列求和
            
            %计算总花费
            str=['总花费为', num2str(sum(Cost))];
            disp(str)
            
            %功率的削峰填谷=================================================
            
            %每个时间段的功率
            Pt=sum(Xm,1);%1对列求和
            P_total=Pt+obj.BasLoad;% 加上居民用电的总功率
            
            str=['功率差=', num2str(max(P_total)-min(P_total))];
            disp(str)
            str=['功率方差=', num2str(var(P_total))];
            disp(str)
            
            %不满意度=====================================================
            
            %每辆车的不满意度
            NS=(sum(Xm,2)-obj.Ep).^2;%2对行求和
            str=['总不满意度=', num2str(sum(NS))];
            disp(str)
            
            
            %画图 归一化处理+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%             Cost_normal=(Cost-30)./(200-30);
%             Pt_normal=(Pt-30)./(100-30);
%             P_total_normal=(P_total-500)./(700-500);
            
            %横坐标为时间
            x = (1:obj.T)*obj.dt;            
            
            f=figure('name','功率');
            a=axes;            
            yyaxis left            
            plot(x,Pt)            
            yyaxis right            
            plot(x,obj.BasLoad)            
            legend('电车功率','居民功率')
            xlabel('time(h)');
            ylabel('power(kw)');
            
            figure('name','总功率')
            plot(x,P_total)
            legend('总功率')
            xlabel('time(h)');
            ylabel('power(kw)');
            ylim([0,1000])


            
            %横坐标为车辆
            %每辆车电量
            figure('name','满意');
            SOCN=sum(Xm,2)*obj.dt*obj.eta/obj.Cap+obj.SOC(:,1);
            xx=1:obj.N;
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'g-',xx,ones(1,obj.N)*0.7,'g-');
            xlabel('car')
            ylim([0.65,0.96]);
            legend('SOC_final','SOC_d','datum line')
            figure('name','不满意度分布')
            histogram(0.9-SOCN,5)
            xticks([0 0.1 0.2])
            xticklabels({'满意','一般','不满意'});
            ylabel('Number of electric car owners')
            axis([0 0.2 0 100])
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

