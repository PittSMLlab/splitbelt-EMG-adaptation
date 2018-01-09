function ep=getExtendedAdaptEpochs()
summ='nanmean'; 
lateStrides=-10;  %For robustness
vEarlyStrides=1;
names={'vShort','Short',...
    'vEarly B','Base',...
    'vEarly A1','late A1',...
    'vEarly A2','late A2',...
    'vEarly A3','late A3',...
    'vEarly P','late P'};
conds=cell(size(names));
exemptF=nan(size(names));
exemptL=nan(size(names));
strides=nan(size(names));
shortNames=cell(size(names));
for i=1:lenght(names)
    eF=0;
    eL=1; %We can exempt one, if we want
    switch names{i}
        case 'vShort'
            s=vEarlyStrides;
            c='Short Exposure';
            sN='veS';
        case 'lShort'
            s=lateStrides;
            c='Short Exposure';
            sN='lS';
        case 'vEarly B'
            s=vEarlyStrides;
            c='TM Base';
            sN='veB';
        case 'Base'
            s=lateStrides;
            c='TM Base';
            sN='lB';
        case 'vEarly A1'
            s=vEarlyStrides;
            c='Adaptation1';
            sN='veA1';
        case 'late A1'
            s=lateStrides;
            c='Adaptation1';
            sN='lA1';
        case 'vEarly A2'
            s=vEarlyStrides;
            c='Adaptation2';
            sN='veA2';
        case 'late A2'
            s=lateStrides;
            c='Adaptation2';
            sN='lA2';
        case 'vEarly A3'
            s=vEarlyStrides;
            c='Adaptation3';
            sN='veA3';
        case 'late A3'
            s=lateStrides;
            c='Adaptation3';
            sN='lA3';
        case 'vEarly P'
            eF=0;
            eL=0;
            s=vEarlyStrides;
            c='Washout';
            sN='veP';
        case 'late P'
            s=lateStrides;
            c='Washout';
            sN='lP';
    end
    conds{i}=c;
    exemptF(i)=eF;
    exemptL(i)=eL;
    strides(i)=s;
    shortNames{i}=sN;
end

ep=defineEpochs(names,conds,strides,exemptF,exemptL,summ,shortNames);
end

