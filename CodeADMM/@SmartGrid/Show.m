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
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'g-');
            xlabel('car');
            legend('SOC_final','SOC_d','datum line')
            figure('name','������ȷֲ�')
            histogram(0.9-SOCN,5)
            xticks([0 0.1 0.2])
            xticklabels({'����','һ��','������'})
            ylabel('Number of electric car owners')
            axis([0 0.2 0 100])
        end