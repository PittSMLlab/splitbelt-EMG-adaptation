function [outputArg1] = auxCosine(inputArg1,inputArg2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
v1=inputArg1./auxNorm(inputArg1);
v2=inputArg2./auxNorm(inputArg2);
outputArg1=diag(v1'*v2);
end

