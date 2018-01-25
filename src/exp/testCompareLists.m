%Test compare lists:

for e=1:5
    switch e
    case 1
        list1={'a','b','c'};
        list2={'1','2','3'};
    case 2
        list1={'1','2','3'};
        list2={'1','2','3'};

    case 3
        list1={'1','1','c'};
        list2={'1','2','3'};
    case 4
        list1={{'a','1'},'b','2'};
        list2={'1','2','3'};
    case 5
        list1={{'a','1'},'2','2'};
        list2={'1','2','3'};
            
    end
    [b1,i1]=compareListsOld(list1,list2);
    [b2,i2]=compareListsNested(list1,list2);

    if any(b1~=b2) || any(i1(b1)~=i2(b1 )) || any(i1(b2)~=i2(b2))
        disp(['Failed test ' num2str(e)])
        i1
        i2
    end
end
