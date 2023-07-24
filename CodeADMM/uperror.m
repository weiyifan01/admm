function err=uperror(X)
[h,L]=size(X);
if L~=1
    err=norm(X);
%     X=reshape(X,[],1);
%     err=X.'*X/L;
else
    err=X.'*X;
end
err=sqrt(err);
end