function [E,R,V,Vv] = recAssess(recData,origData)
[R] = R2(recData,origData);
[E] = EAF(recData,origData);
[V] = VAF(recData,origData);
[Vv] = VAFv(recData,origData);

end

