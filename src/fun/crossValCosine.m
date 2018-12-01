function [c] = crossValCosine(data)

for i=1:size(data,2)
   c(i)=auxCosine(data(:,i),median(data(:,[1:i-1,i+1:end]),2)); 
end

end

