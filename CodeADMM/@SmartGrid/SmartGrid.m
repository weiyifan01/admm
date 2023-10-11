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
            memory
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
            
            
            %��ͼ ��һ������+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%             Cost_normal=(Cost-30)./(200-30);
%             Pt_normal=(Pt-30)./(100-30);
%             P_total_normal=(P_total-500)./(700-500);
            
            %������Ϊʱ��
            x = (1:obj.T)*obj.dt;            
            
            f=figure('name','����');
            a=axes;            
            yyaxis left            
            plot(x,Pt)            
            yyaxis right            
            plot(x,obj.BasLoad)            
            legend('�糵����','������')
            xlabel('time(h)');
            ylabel('power(kw)');
            
            figure('name','�ܹ���')
            plot(x,P_total)
            legend('�ܹ���')
            xlabel('time(h)');
            ylabel('power(kw)');
            ylim([0,1000])


            
            %������Ϊ����
            %ÿ��������
            figure('name','����');
            SOCN=sum(Xm,2)*obj.dt*obj.eta/obj.Cap+obj.SOC(:,1);
            xx=1:obj.N;
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'g-',xx,ones(1,obj.N)*0.7,'g-');
            xlabel('car')
            ylim([0.65,0.96]);
            legend('SOC_final','SOC_d','datum line')
            figure('name','������ȷֲ�')
            histogram(0.9-SOCN,5)
            xticks([0 0.1 0.2])
            xticklabels({'����','һ��','������'});
            ylabel('Number of electric car owners')
            axis([0 0.2 0 100])
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

