classdef SmartGrid < Prepare
    %�����������ò��������ý��������չʾ�������
    
    properties
        P; %N��T�� ��P_{n,t}��ɵľ���
        W=[1,1,1,1]; %����Ŀ�꺯����Ȩ�� [�ܵ�ѣ�������ȣ������ȶ���L0���ʱ��]
        epsilon_pri=1;% �������
        rho=0.5;
        
        AA; % ����Լ��
        bb; % ����Լ��
        UUB; % �Ͻ�
        LLB; %�½�
    end
    
    methods
        function obj = SmartGrid()
            % ͨ������Prepare����ʼ��
            obj =  obj@Prepare();
        end
        
        function Solve(obj,k) %������ⷽ��
            switch k
                case 1 %����Ϊһ�������Ż����⣬һ����λ
                    Ablbub(obj,1) %�����Ӧ��Լ������
                    Xv=ADMM_1(obj);
                    obj.P=reshape(Xv,obj.T,obj.N).'; %������ع�Ϊ������
                case 2 %�����ADMM
                    Ablbub(obj,2)%�����Ӧ��Լ������
                    Xv=ADMM_2(obj);
                    obj.P=reshape(Xv,obj.T,obj.N).';
                case 3 %N+1���ADMM���ҿɲ��д���
                    Ablbub(obj,3)%�����Ӧ��Լ������
                    [Pk]=Jacobi_Proximal_ADMM(obj); %Pk(T��N+1)
                    obj.P=Pk(:,1:end-1).'; %��ȥ���һ�е� �����
            end
        end
        
        %�Խ������չʾ
        function Show(obj)
            %X (100,96)
            %������ʽ��
            Xv=reshape(obj.P.',[],1);    %�����: Xm=reshape(Xv,obj.T,obj.N).';
            
            
            %������ʽ��
            Xm=obj.P;
            
            %_________________________________________________________
            %���
            CC=obj.ElePrice*obj.dt;
            %ÿ�׶λ���
            Cost=sum(Xm.*CC,1);%1�������
            
            % �ܻ���
            str=['�ܻ���Ϊ', num2str(sum(Cost))];
            disp(str)
            %_________________________________________________________
            
            %ÿ�׶ι���
            Pt=sum(Xm,1);%1�������
            P_total=Pt+obj.BasLoad;
            
            str=['���ʲ�=', num2str(max(P_total)-min(P_total))];
            disp(str)
            str=['���ʷ���=', num2str(var(P_total))];
            disp(str)
            
            %�����
            satisfy=0;
            Ep=-obj.Ep;
            H=ones(obj.T,obj.T)*2;
            for k=1:obj.N
                SOC09=Ep(k).^2;
                
                % 1/2 V^T H V+ f V
                
                f=2*Ep(k)*ones(obj.T,1);                
                satisfy=satisfy+1/2*Xm(k,:)*H*Xm(k,:)'+f'*Xm(k,:)'+SOC09;
            end
            str=['�������Ϊ', num2str(satisfy)];
            disp(str)
            
            
            
            
            figure(1)
            plot((1:obj.T)*obj.dt,Cost,'r-',(1:obj.T)*obj.dt,Pt,'b-.',(1:obj.T)*obj.dt,P_total-500,'g-*');
            xlabel('time');
            
            legend('Cost','Power','Power_total-500')
            
            %ÿ��������
            figure(2);
            SOCN=sum(Xm,2)*obj.dt*obj.eta/obj.Cap+obj.SOC(:,1);
            xx=1:obj.N;
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'y-');
            xlabel('time');
            legend('SOC_final','SOC_d')
            
        end
        
        
        
        %Լ������
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
                    %���ܵ����������
                    for k=1:obj.N
                        kk=kk+1;
                        obj.AA(kk,1+(k-1)*obj.T:k*obj.T)=obj.A(kk,:);
                        obj.bb(kk)=obj.b(kk,:);
                    end
                    obj.LLB=reshape(obj.lb.',[],1);  %δ������뿪�� ���״̬Ϊ0   %�μ�����(22)�� ��23��ʽ
                    obj.UUB=reshape(obj.ub.',[],1); %���������ߣ����Ե���������Լ��  %�μ�����(25)ʽ
                case 3
                    obj.AA=obj.A;
                    obj.bb=obj.b;
                    obj.LLB=obj.lb;
                    obj.UUB=obj.ub;
            end
            
        end
        
        
    end
end

