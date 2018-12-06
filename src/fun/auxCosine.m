function [outputArg1] = auxCosine(inputArg1,inputArg2)
%Computes cosines of row-vectors. If two arguments are given, the
%comparison is first vector of argument one to first of argument two, and
%so on. If a single argument is given, all rows of are compared to all
%others (except themselves). In this case result is a symmetric matrix with
%NaN diagonal elements.
v1=inputArg1./auxNorm(inputArg1);
if nargin>1
    v2=inputArg2./auxNorm(inputArg2);
    outputArg1=diag(v1'*v2);
else%Single input
    outputArg1=v1'*v1 +diag(nan(size(v1,2),1));
end
end

