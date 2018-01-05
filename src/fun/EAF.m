function [E] = EAF(recData,origData)
%Check matrix sizes:

E=1-norm(recData-origData,'fro')^2/norm(origData,'fro')^2;
%=trace(recData'*recData)+trace(origData'*origData)-2*trace(recData'*origData)/
%=1+norm(rec)^2/norm(orig)^2 - 

%Alt: I think this is NOT equivalent, but the difference seems to go away
%with well behaved data. This definition, to start with, cannot be negative. WTF?
%E=trace((recData'*origData)).^2/(norm(origData,'fro')^2 * norm(recData,'fro')^2);
end

