classdef Prepare < handle
    % 根据设定参数生成满足要求的随机值，为后面计算做准备
    properties
        N; %number of car
        dt;% interval time
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
        function obj = Prepare(N,dt)
            obj.N=N;obj.dt=dt;obj.T=24/dt;
            %计算分时电价 和 基础荷载=======================================
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
            
            %计算到达和离开的时间===========================================
            
            [Gamma,SOC]=generate_random(obj);
            %根据特定分布函数生成随机到达和离开时间 及 到达离开的电池状态
            obj.Gamma=Gamma;
            obj.SOC=SOC;
            
            %根据离开电量设置线性不等式约束条件===================================
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
            
            %根据到达离开到达时间设置上下界约束条件==========================
            ub=zeros(obj.N,obj.T); %自变量上界  %列对应电车，行对应时间
            lb=zeros(obj.N,obj.T); %自变量下界
            
            for i=1:obj.N
                %车不到，功率最大为0
                b_temp=[zeros(1,Gamma(i,1)),obj.Pmax*ones(1,Gamma(i,2)-Gamma(i,1)),zeros(1,2*obj.T-Gamma(i,2))];
                b_temp=b_temp(1:obj.T)+b_temp(obj.T+1:2*obj.T);
                ub(i,:)=b_temp;
                
                %lb %慢充模式没有任何一个时间区间是必须充电的。
                
            end
            
            obj.lb=lb;
            obj.ub=ub;
            
            %期望达到的充电水平
            obj.Ep=(0.9-obj.SOC(:,1))*obj.Cap/(obj.dt*obj.eta);
        end
        
        function generate_random_plot(obj) %根据特定分布函数生成随机到达和离开时间
            
            %首先计算到达
            muhc=18;
            sighc=3.3;
            
            R0=normrnd(muhc,sighc,obj.N,1);%？
            X=0:0.1:24-0.1;
            Y=normpdf([X,X+24],muhc,sighc);
            Y=Y(1:length(X))+Y(length(X)+1:end);
            for k=1:obj.N
                if R0(k) >24
                    R0(k)=R0(k)-24;%？
                end
            end
            figure('name','D1');
            
            plot(X,Y,'r-');hold on
            histogram(R0,20,'Normalization','pdf')
            
%             yticks(0:obj.N/40:obj.N/10)
%             yticklabels({'0','0.025','0.05','0.075','0.1'})
            xlabel('time')
            ylabel('probability')            
            title('Distribution of arrival times with mu=18 and sigma=3.3')
            axis([0,24,0,inf])
            
            %首先计算离开
            muhd=8;
            sighd=3.24;
            
            R1=normrnd(muhd,sighd,obj.N,1);
            X=0:0.1:24-0.1;
            Y=normpdf([X,X+24],muhd,sighd);
            Y=Y(1:length(X))+Y(length(X)+1:end);
            
            for k=1:obj.N
                if R1(k) <0
                    R1(k)=R1(k)+24;
                end
            end
            figure('name','D2');
            
            plot(X,Y,'r-');hold on
            histogram(R1,20,'Normalization','pdf')
            xlabel('time')
            ylabel('probability')
            title('Distribution of departure time  with mu=8 and sigma=3.24')
            %xlim( )
            axis([0,24,0,inf])
        end
        
        function PricandLoad(obj) %画出分时电价和居民荷载

            figure('name','price')
            bar((1:obj.T)*obj.dt,obj.ElePrice,'BarWidth',0.8,'LineStyle','none','facecolor','cyan')
            xlabel('time$(h)$','interpreter','latex')
            ylabel('price$(CNY)$','interpreter','latex')
%             set(gca,)
            title('Price of electricity at different times')
            ylim([0,1.2])
            
            figure('name','base')
            x=0:0.05:24;Y=x;
            for k=1:length(x)
                obj.time=x(k);
                Y(k)=Residential_electricity_consumption(obj);
            end
            bar(x,Y,'c','BarWidth',1,'LineStyle','none')
            xlabel('time$(h)$','interpreter','latex')
            ylabel('power($kw$)','interpreter','latex')
            title('Residential power distribution with time')
            ylim([0,800])
        end
    end
end

