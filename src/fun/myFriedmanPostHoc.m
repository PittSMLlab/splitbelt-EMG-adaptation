function [C] = myFriedmanPostHoc(data,reps)
%A Friedman post-hoc done by running friedman's on pairs of treatments
%data has to have one column per treatment, and one row per observation,
%syntax is same as friedman

%Assuming only 3 groups:
nGroups=size(data,2);
C=nan(nGroups*(nGroups-1)/2,6);
counter=0;
for i=1:nGroups %
    for j=i+1:nGroups
        counter=counter+1;
        C(counter,1)=i; %Treatment 1 to compare
        C(counter,2)=j; %Treatment 2 to compare
        [C(counter,6),~,stats]=friedman(data(:,[i,j]),reps,'off'); %Run Friedman with two groups only. Without replicates this should be equivalent to a signrank test. With replicates it is a more sophisticated version of the ranksum (MWW U-test)
        C(counter,4)=diff(stats.meanranks);
        C(counter,3)=diff(stats.meanranks)-stats.sigma;
        C(counter,5)=diff(stats.meanranks)+stats.sigma;
    end
end



end

