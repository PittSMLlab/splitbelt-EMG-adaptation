function expData=loadProcessed(sub,matDataDir,avoidIDcheck)

        %Step 1: load file
        filename{1}=[matDataDir '/sub' sub 'Processed.mat'];
        filename{2}=[matDataDir '/sub' sub '.mat'];
        filename{3}=[matDataDir '/' sub '.mat'];
        fileFlag=cellfun(@(x) exist(x,'file'),filename);
        if sum(fileFlag~=0)>1
            error('loadProcessedFile:multipleMatchingFiles','Found more than one .mat file that could match the requested data')
        elseif sum(fileFlag~=0)==0
            disp(matDataDir)
            disp(sub)
            error('loadProcessedFile:noMatchingFiles',['Did not find .mat file that could match the requested data.'])
            
        else
            a=load(filename{fileFlag~=0});
        end
        
        %Step 2: assign output var to expData
        aux=fieldnames(a);
        expData=a.(aux{1});
        %Step 3: check ID of loaded sub
        if ~exist('expData','var')
            if  (isempty(strfind(lower(sub),lower(expData.subData.ID))) && isempty(strfind(['sub' lower(sub)],lower(expData.subData.ID))))
                if nargin<3 || isempty(avoidIDcheck) || avoidIDcheck~=1 
                    error('loadProcessedFile:IDmismatch','Processed file loading did not return a subject ID matching the expected value.')
                else
                    warning('loadProcessedFile:IDmismatch','Processed file loading did not return a subject ID matching the expected value.')
                end
            end
        end
    