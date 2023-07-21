classdef Prepare < handle
    % 根据设定参数生成满足要求的随机值，为后面计算做准备
    properties
        N=100; %number of car
        dt=60/60;% interval time
        T; %number of interval
        
        ElePrice; % electrovalence (行向量)
        BasLoad % Basic load(基础荷载)(行向量)
        A; %非线性约束(每行对应一辆车)
        b; %非线性约束
        lb; %lower bound
        ub; %upper bound
        
        Ep;%期望的功率
        
        eta=0.9;%充电效率
        Cap=30;%电池效率
        SOC;%到达和离开的电池电量
    end
    properties (Access = private )
        Pmax=7;%最大充电功率
        Gamma;%到达和离开的时间区间编号        
        time;
    end
    
    methods
        function obj = Prepare()
            obj.T=24/obj.dt;
            ElePrice_Fee=zeros(1,obj.T); %分时电价
            BasicLoad=zeros(1,obj.T);   %基础荷载
            for j=1:obj.T
                obj.time= (j+0.5)*obj.dt;
                
                %j阶段电价
                ElePrice_Fee(j)=Ele_price(obj);
                
                %基础负荷
                BasicLoad(j)=Residential_electricity_consumption(obj);
            end
            
            obj.ElePrice=ElePrice_Fee;
            obj.BasLoad=BasicLoad;
            %===================================
            
            [Gamma,SOC]=generate_random(obj);
            %根据特定分布函数生成随机到达和离开时间 及 到达离开的电池状态
            obj.Gamma=Gamma;
            obj.SOC=SOC;
            
            %根据离开电量设置线性约束条件
            A=zeros(2*obj.N,obj.T);  %对每辆车的限制
            b=zeros(2*obj.N,1);
            kk=0;
            %电池不能充爆
            for k=1:obj.N
                kk=kk+1;
                A(kk,:)=obj.dt*obj.eta;
                b(kk)=(1-obj.SOC(k,1))*obj.Cap;
            end
            %不能低于最低期望
            for k=1:obj.N
                kk=kk+1;
                A(kk,:)=-obj.dt*obj.eta;
                b(kk)=-(obj.SOC(k,2)-obj.SOC(k,1))*obj.Cap;
            end
            
            obj.A=A;
            obj.b=b;
            
            %根据离开离开到达时间设置线性约束条件
            ub=zeros(obj.N,obj.T); %自变量上界  %列对应电车，行对应时间
            lb=zeros(obj.N,obj.T);  %自变量下界
            
            for i=1:obj.N
                %车不到，功率最大为0
                b_temp=[zeros(1,Gamma(i,1)),obj.Pmax*ones(1,Gamma(i,2)-Gamma(i,1)),zeros(1,2*obj.T-Gamma(i,2))];
                b_temp=b_temp(1:obj.T)+b_temp(obj.T+1:2*obj.T);
                
                %lb %慢充模式没有任何一个时间区间是必须充电的。
                ub(i,:)=b_temp;
            end
            
            obj.lb=lb;
            obj.ub=ub;
            
            obj.Ep=(0.9-obj.SOC(:,1))*obj.Cap/(obj.dt*obj.eta);
        end
        
        function generate_random_plot(obj) %根据特定分布函数生成随机到达和离开时间
            
            %首先计算到达
            muhc=18;
            sighc=3.3;
            
            R0=normrnd(muhc,sighc,obj.N,1);%？
            
            
            for k=1:obj.N
                if R0(k) >24
                    R0(k)=R0(k)-24;%？
                end
            end
            figure(1);
            histogram(R0,10)
            
            %首先计算离开
            muhc=8;
            sighc=3.24;
            
            R1=normrnd(muhc,sighc,obj.N,1);
            
            for k=1:obj.N
                if R1(k) <0
                    R1(k)=R1(k)+24;
                end
            end
            figure(2);
            histogram(R1,10)
        end
        
        function PricandLoad(obj) %画出分时电价和居民荷载
            x=1:obj.T;
            y=zeros(2,obj.T);
            for k=1:obj.T
                obj.time=k*obj.dt;
                [Load1]=Ele_price(obj);
                
                [Load2]=Residential_electricity_consumption(obj);
                y(:,k)=[Load1;Load2];
            end
            figure(1)
            plot(x,y(1,:),'-')
            figure(2)
            plot(x,y(2,:),'.-')
        end
    end
end

