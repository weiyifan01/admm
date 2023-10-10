classdef SmartGrid < Prepare
    %�����������ò��������ý��������չʾ�������
    
    properties
        P; %N��T�� ��P_{n,t}��ɵľ���
       
        W=[1,1,1,1]; %����Ŀ�꺯����Ȩ�� [�ܵ�ѣ�������ȣ������ȶ���L0���ʱ��
        
        AA;  % ����Լ��
        bb;  % ����Լ��
        UUB; % �Ͻ�
        LLB; % �½�
        result; % �洢�������
    end
    
    methods
        function obj = SmartGrid(N,dt)
            % ͨ������Prepare����ʼ��
            obj =  obj@Prepare(N,dt);
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
                    [Pk,result0]=Jacobi_Proximal_ADMM(obj,rho,gamma); %Pk(T��N+1)
                    obj.P=Pk(:,1:end-1).'; %��ȥ���һ�е� �����
                    obj.result=result0;
            end
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

