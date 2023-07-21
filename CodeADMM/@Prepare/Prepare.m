classdef Prepare < handle
    % �����趨������������Ҫ������ֵ��Ϊ���������׼��
    properties
        N=100; %number of car
        dt=60/60;% interval time
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
        function obj = Prepare()
            obj.T=24/obj.dt;
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
            %===================================
            
            [Gamma,SOC]=generate_random(obj);
            %�����ض��ֲ������������������뿪ʱ�� �� �����뿪�ĵ��״̬
            obj.Gamma=Gamma;
            obj.SOC=SOC;
            
            %�����뿪������������Լ������
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
            
            %�����뿪�뿪����ʱ����������Լ������
            ub=zeros(obj.N,obj.T); %�Ա����Ͻ�  %�ж�Ӧ�糵���ж�Ӧʱ��
            lb=zeros(obj.N,obj.T);  %�Ա����½�
            
            for i=1:obj.N
                %���������������Ϊ0
                b_temp=[zeros(1,Gamma(i,1)),obj.Pmax*ones(1,Gamma(i,2)-Gamma(i,1)),zeros(1,2*obj.T-Gamma(i,2))];
                b_temp=b_temp(1:obj.T)+b_temp(obj.T+1:2*obj.T);
                
                %lb %����ģʽû���κ�һ��ʱ�������Ǳ�����ġ�
                ub(i,:)=b_temp;
            end
            
            obj.lb=lb;
            obj.ub=ub;
            
            obj.Ep=(0.9-obj.SOC(:,1))*obj.Cap/(obj.dt*obj.eta);
        end
        
        function generate_random_plot(obj) %�����ض��ֲ������������������뿪ʱ��
            
            %���ȼ��㵽��
            muhc=18;
            sighc=3.3;
            
            R0=normrnd(muhc,sighc,obj.N,1);%��
            
            
            for k=1:obj.N
                if R0(k) >24
                    R0(k)=R0(k)-24;%��
                end
            end
            figure(1);
            histogram(R0,10)
            
            %���ȼ����뿪
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
        
        function PricandLoad(obj) %������ʱ��ۺ;������
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

