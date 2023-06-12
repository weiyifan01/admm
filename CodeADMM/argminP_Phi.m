function [Pk1]=argminP_Phi(Pk,Yk,muk)
FUN=@(P) G(P)+I1(P)+I2(Yk)+1/2*norm()
Pk1 = fminunc(FUN,0);
end