function ep=getEpochs()
summ='nanmean'; 
earlyStrides=15;
lateStrides=-40; 
vEarlyStrides=1;
names={'Slow','vShort','Short',...
    'vEarly B','early B','Base',...
    'vEarly A','early A','late A',...
    'vEarly P','early P','late P'};
names=names(1:end); %Excluding Slow
conds=cell(size(names));
exemptF=nan(size(names));
exemptL=nan(size(names));
strides=nan(size(names));
shortNames=cell(size(names));
for i=1:length(names)
    switch names{i}
        case 'vShort'
            eF=0;
            eL=0;
            s=vEarlyStrides;
            c='Short Exposure';
            sN='veS';
        case 'Short'
            eF=1;
            eL=1;
            s=8;
            c='Short Exposure';
            sN='S';
        case 'vEarly B'
            eF=0;
            eL=0;
            s=vEarlyStrides;
            c='TM Base';
            sN='veB';
        case 'early B'
            eF=1;
            eL=1;
            s=earlyStrides;
            c='TM Base';
            sN='eB';
        case 'Base'
            eF=1;
            eL=1;
            s=lateStrides;
            c='TM Base';
            sN='B';
        case 'vEarly A'
            eF=0;
            eL=0;
            s=vEarlyStrides;
            c='Adaptation';
            sN='veA';
        case 'early A'
            eF=1;
            eL=1;
            s=earlyStrides;
            c='Adaptation';
            sN='eA';
        case 'late A'
            eF=1;
            eL=1;
            s=lateStrides;
            c='Adaptation';
            sN='lA';
        case 'vEarly P'
            eF=0;
            eL=0;
            s=vEarlyStrides;
            c='Washout';
            sN='veP';
        case 'early P'
            eF=1;
            eL=1;
            s=earlyStrides;
            c='Washout';
            sN='eP';
        case 'late P'
            eF=1;
            eL=1;
            s=lateStrides;
            c='Washout';
            sN='lP';
        case 'Slow'
            eF=1;
            eL=1;
            s=-30;
            c='TM slow';
            sN='Sl';
    end
    conds{i}=c;
    exemptF(i)=eF;
    exemptL(i)=eL;
    strides(i)=s;
    shortNames{i}=sN;
end
ep=defineEpochs(names,conds,strides,exemptF,exemptL,summ,shortNames);
end

