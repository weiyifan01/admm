classdef Prepare < handle
    % �����趨������������Ҫ������ֵ��Ϊ���������׼��
    properties
        N; %number of car
        dt;% interval time
        T; %number of interval
        
        ElePrice; % electrovalence (������)
        BasLoad % Basic load(��������)(������)
        A; %������Լ��(ÿ�ж�Ӧһ����)
        b; %������Լ��
        lb; %lower bound
        ub; %upper bound
        
        Ep;%�����Ĺ���
        
        eta=0.9;%���Ч��
        Cap=30;%���Ч��
        SOC;%������뿪�ĵ�ص���
    end
    properties (Access = private )
        Pmax=7;%����繦��
        Gamma;%������뿪��ʱ��������        
        time;
    end
    
    methods
        function obj = Prepare(N,dt)
            obj.N=N;obj.dt=dt;obj.T=24/dt;
            %�����ʱ��� �� ��������=======================================
            ElePrice_Fee=zeros(1,obj.T); %��ʱ���
            BasicLoad=zeros(1,obj.T);   %��������
            for j=1:obj.T
                obj.time= (j+0.5)*obj.dt;
                
                %j�׶ε��
                ElePrice_Fee(j)=Ele_price(obj);
                
                %��������
                BasicLoad(j)=Residential_electricity_consumption(obj);
            end
            
            obj.ElePrice=ElePrice_Fee;
            obj.BasLoad=BasicLoad;
            
            %���㵽����뿪��ʱ��===========================================
            
            [Gamma,SOC]=generate_random(obj);
            %�����ض��ֲ������������������뿪ʱ�� �� �����뿪�ĵ��״̬
            obj.Gamma=Gamma;
            obj.SOC=SOC;
            
            %�����뿪�����������Բ���ʽԼ������===================================
            A=zeros(2*obj.N,obj.T);  %��ÿ����������
            b=zeros(2*obj.N,1);
            kk=0;
            %��ز��ܳ䱬
            for k=1:obj.N
                kk=kk+1;
                A(kk,:)=obj.dt*obj.eta;
                b(kk)=(1-obj.SOC(k,1))*obj.Cap;
            end
            %���ܵ����������
            for k=1:obj.N
                kk=kk+1;
                A(kk,:)=-obj.dt*obj.eta;
                b(kk)=-(obj.SOC(k,2)-obj.SOC(k,1))*obj.Cap;
            end
            
            obj.A=A;
            obj.b=b;
            
            %���ݵ����뿪����ʱ���������½�Լ������==========================
            ub=zeros(obj.N,obj.T); %�Ա����Ͻ�  %�ж�Ӧ�糵���ж�Ӧʱ��
            lb=zeros(obj.N,obj.T); %�Ա����½�
            
            for i=1:obj.N
                %���������������Ϊ0
                b_temp=[zeros(1,Gamma(i,1)),obj.Pmax*ones(1,Gamma(i,2)-Gamma(i,1)),zeros(1,2*obj.T-Gamma(i,2))];
                b_temp=b_temp(1:obj.T)+b_temp(obj.T+1:2*obj.T);
                ub(i,:)=b_temp;
                
                %lb %����ģʽû���κ�һ��ʱ�������Ǳ�����ġ�
                
            end
            
            obj.lb=lb;
            obj.ub=ub;
            
            %�����ﵽ�ĳ��ˮƽ
            obj.Ep=(0.9-obj.SOC(:,1))*obj.Cap/(obj.dt*obj.eta);
        end
        
        function generate_random_plot(obj) %�����ض��ֲ������������������뿪ʱ��
            
            %���ȼ��㵽��
            muhc=18;
            sighc=3.3;
            
            R0=normrnd(muhc,sighc,obj.N,1);%��
            X=0:0.1:24-0.1;
            Y=normpdf([X,X+24],muhc,sighc);
            Y=Y(1:length(X))+Y(length(X)+1:end);
            for k=1:obj.N
                if R0(k) >24
                    R0(k)=R0(k)-24;%��
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
            
            %���ȼ����뿪
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
        
        function PricandLoad(obj) %������ʱ��ۺ;������

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

