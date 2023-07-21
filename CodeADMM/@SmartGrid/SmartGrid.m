classdef SmartGrid < Prepare
    %�����������ò��������ý��������չʾ�������
    
    properties
        P; %N��T�� ��P_{n,t}��ɵľ���
       
        W=[1,1,1,1]; %����Ŀ�꺯����Ȩ�� [�ܵ�ѣ�������ȣ������ȶ���L0���ʱ��
        
        AA;  % ����Լ��
        bb;  % ����Լ��
        UUB; % �Ͻ�
        LLB; % �½�
    end
    
    methods
        function obj = SmartGrid()
            % ͨ������Prepare����ʼ��
            obj =  obj@Prepare();
        end
        

        function Solve(obj,rho,gamma) %ѡ��ͬ����ⷽ�� 
            switch nargin
                case 1 %����Ϊһ�������Ż����⣬һ����λ
                    Ablbub(obj,1) %�����Ӧ��Լ������
                    Xv=ADMM_1(obj);
                    obj.P=reshape(Xv,obj.T,obj.N).'; %������ع�Ϊ������
                case 2 %�����ADMM
                    Ablbub(obj,2)%�����Ӧ��Լ������
                    Xv=ADMM_2(obj,rho);
                    obj.P=reshape(Xv,obj.T,obj.N).';
                case 3 %N+1���ADMM���ҿɲ��д���
                    Ablbub(obj,3)%�����Ӧ��Լ������
                    [Pk]=Jacobi_Proximal_ADMM(obj,rho,gamma); %Pk(T��N+1)
                    obj.P=Pk(:,1:end-1).'; %��ȥ���һ�е� �����
            end
        end
        
        
        function Show(obj) %�Խ������չʾ
            %������Pת��Ϊ���ʵ���״����������
            %������ʽ��
            Xv=reshape(obj.P.',[],1);    %�����: Xm=reshape(Xv,obj.T,obj.N).';        
            %������ʽ��
            Xm=obj.P;
            
            %չʾ�ܵ��=====================================================
            
            CC=obj.ElePrice*obj.dt;
            %ÿ�׶λ���
            Cost=sum(Xm.*CC,1);%1�������
            
            %�����ܻ���
            str=['�ܻ���Ϊ', num2str(sum(Cost))];
            disp(str)
            
            %���ʵ��������=================================================
            
            %ÿ��ʱ��εĹ���
            Pt=sum(Xm,1);%1�������
            P_total=Pt+obj.BasLoad;% ���Ͼ����õ���ܹ���
            
            str=['���ʲ�=', num2str(max(P_total)-min(P_total))];
            disp(str)
            str=['���ʷ���=', num2str(var(P_total))];
            disp(str)
            
            %�������=====================================================
            
            %ÿ�����Ĳ������
            NS=(sum(Xm,2)-obj.Ep).^2;%2�������
            str=['�ܲ������=', num2str(sum(NS))];
            disp(str)
            
            
            %��ͼ+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
            %������Ϊʱ��
            figure(1)
            plot((1:obj.T)*obj.dt,Cost,'r-',(1:obj.T)*obj.dt,Pt,'b-.',(1:obj.T)*obj.dt,P_total-500,'g-*');
            xlabel('time');
            
            legend('Cost','Power','Power_total-500')
            
            %������Ϊ����
            %ÿ��������
            figure(2);
            SOCN=sum(Xm,2)*obj.dt*obj.eta/obj.Cap+obj.SOC(:,1);
            xx=1:obj.N;
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'g-');
            xlabel('car');
            legend('SOC_final','SOC_d','datum line')
        end
        
        
        %���Լ������
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

