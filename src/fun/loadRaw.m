function rawExpData=loadRaw(sub,matDataDir,avoidIDcheck)

        %Step 1: load file
        filename{1}=[matDataDir '/raw/sub' sub 'RAW.mat'];
        filename{2}=[matDataDir '/raw/' sub 'RAW.mat'];
        filename{3}=[matDataDir '/' sub 'RAW.mat'];
        fileFlag=cellfun(@(x) exist(x,'file'),filename);
        if sum(fileFlag~=0)>1
            error('loadRawFile:multipleMatchingFiles','Found more than one .mat file that could match the requested data')
        elseif sum(fileFlag~=0)==0
            error('loadRawFile:noMatchingFiles','Did not find .mat file that could match the requested data')
        else
            a=load(filename{fileFlag~=0});
        end
        
        %Step 2: assign output var to expData
        aux=fieldnames(a);
        rawExpData=a.(aux{1});
        %Step 3: check ID of loaded sub
        if ~exist('rawExpData','var') || (isempty(strfind(lower(sub),lower(rawExpData.subData.ID))) && isempty(strfind(['sub' lower(sub)],lower(rawExpData.subData.ID))))
            if nargin<3 || isempty(avoidIDcheck) || avoidIDcheck~=1 
                error('loadRawFile:failedToLoad','Processed file loading failed: output rawExpData not as expected')
            else
                warning('loadRawFile:failedToLoad','Processed file loading failed: output rawExpData not as expected')
            end
        end  
    