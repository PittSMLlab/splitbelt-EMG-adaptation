function [Y,name] = doDataNormalization(X)
%A) Max-amplitude normalized
Y{2} = bsxfun(@rdivide,X, max(X));
name{2}='Max-amp';

%B) Variance normalized
Y{1} = bsxfun(@rdivide,X, std(X,1));
name{1}='Var';

%C) Energy normalized
Y{3} = bsxfun(@rdivide,X, sqrt(sum(X.^2,1)));
name{3}='Energy';

%D) Mean amplitude normalized
Y{4} = bsxfun(@rdivide,X, mean(X));
name{4}='Mean-amp';
end

