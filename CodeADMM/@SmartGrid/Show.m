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
            plot(xx,SOCN,'ro-',xx,obj.SOC(:,2),'b*-.',xx,ones(1,obj.N)*0.9,'g-');
            xlabel('car');
            legend('SOC_final','SOC_d','datum line')
            figure('name','不满意度分布')
            histogram(0.9-SOCN,5)
            xticks([0 0.1 0.2])
            xticklabels({'满意','一般','不满意'})
            ylabel('Number of electric car owners')
            axis([0 0.2 0 100])
        end