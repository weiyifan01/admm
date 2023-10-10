function ShowIteration(obj)
% data1=obj.result(1,:)./max(obj.result(1,:));
% data2=obj.result(2,:)./max(obj.result(2,:));
data1=obj.result(1,:);
data2=obj.result(2,:);

time=obj.result(3,:);
figure('Name','Reduction of error')
semilogy(time,data1,'b-.',time,data2,'g-.',time,data1+data2,'r-.');
legend('原始误差','残量误差','总误差')
TT=strcat(' rho=',num2str(1/obj.N));title(TT);
% xlim([20,100])
ylabel('L2-error')
xlabel('iterations time')
end