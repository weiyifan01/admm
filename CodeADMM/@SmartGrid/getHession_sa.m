function [H,f,SOC09]=getHession_sa(obj)
            %P, (1,M)
            N=obj.N;
            M=obj.T;
            
            Ep=-obj.Ep;
            
            H=kron(diag(ones(N,1)),ones(M,M))*2;
            
            SOC09=sum(Ep.^2);
            
            % 1/2 V^T H V+ f V
            
            f=kron(2*Ep,ones(M,1));
        end